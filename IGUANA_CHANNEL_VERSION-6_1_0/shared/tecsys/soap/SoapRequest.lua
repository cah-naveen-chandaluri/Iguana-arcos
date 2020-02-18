-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.
 
require 'tecsys.soap.SoapProperties'
require 'tecsys.soap.SoapAuthenticator'
require 'tecsys.soap.SoapBuilder'
require 'tecsys.util.StringUtil'
require 'tecsys.util.Util'

local Cache = require "tecsys.util.Cache"
local SoapResponse = require "tecsys.soap.SoapResponse"
local HTTP_TIMEOUT = 60

local this = {}
SoapRequest = {}

SoapRequest.Action = {
   Create="create", 
   Update="update", 
   Delete="delete", 
   CreateOrUpdate="createOrUpdate", 
   CreateOrReplace="createOrReplace"}

SoapRequest.Type = {
   SEARCH=1, 
   UPDATE=2, 
   APPLICATION=3}

--WS UPDATE
function SoapRequest.update(action, databaseName, xmlDataNode, username, password, removeEmptyTags, qualifier)

   if removeEmptyTags or isNilOrEmpty(removeEmptyTags) then
      node.removeEmptyChildNode(xmlDataNode[1])
   end   

   return SoapRequest.updateRequest(action, databaseName, xmlDataNode, username, password, qualifier)
end 

function SoapRequest.updateRequest(action, databaseName, xmlDataNode, username, password, qualifier)

   if isNilOrEmpty(username) then
      username = SoapProperties.getUsername(qualifier)
   end

   if isNilOrEmpty(qualifier) then qualifier = "" end
   local sessionId = SoapBuilder.getSessionId(databaseName, qualifier)

   if isNilOrEmpty(sessionId) then
      trace(databaseName, username, password, qualifier)
      sessionId = SoapAuthenticator.login(databaseName, username, password, qualifier)
   end

   if isNilOrEmpty(action) then
      action = SoapRequest.Action.CreateOrUpdate
   end

   local xmlBody = xml.parse{data = this.getUpdateBody(databaseName)}
   local arg0 = xmlBody["soapenv:Envelope"]["soapenv:Body"]["wsc:update"].arg0
   arg0.userName:setInner(username)
   arg0.sessionId:setInner(sessionId)

   local childCount = arg0:childCount("transactions")

   if type(xmlDataNode) == 'string' then
      arg0:append(xml.ELEMENT, "transactions")
      arg0:child("transactions", childCount):append(xml.ELEMENT, "action")
      arg0:child("transactions", childCount):append(xml.ELEMENT, "data")
      arg0:child("transactions", childCount).action:setInner(action)
      arg0:child("transactions", childCount).data:setInner(xmlDataNode)
   else   
      for i = 1, #xmlDataNode do
         arg0:append(xml.ELEMENT, "transactions")
         arg0:child("transactions", childCount):append(xml.ELEMENT, "action")
         arg0:child("transactions", childCount):append(xml.ELEMENT, "data")
         arg0:child("transactions", childCount).action:setInner(action)
         arg0:child("transactions", childCount).data:setInner(xmlDataNode[childCount]:S())
      end
   end   

   return this.makeSoapRequest(xmlBody:S(), SoapRequest.Type.UPDATE, databaseName, username, password, qualifier)
end

function SoapRequest.getDataNode(viewName, userName, qualifier)

   if isNilOrEmpty(qualifier) then qualifier = '' end
   
   --Get alt ID
   local xmlXsd = SoapRequest.getXsd{viewName=viewName, userName=userName, qualifier=qualifier}

   local xsdNode = xml.parse{data=xmlXsd}
   local altId = xsdNode["xs:schema"]["xs:element"].name:nodeValue()
   local columnNode = xsdNode["xs:schema"]["xs:element"]["xs:complexType"]["xs:sequence"]
   local columnCount = columnNode:childCount("xs:element")

   local dataNode = xml.parse{data='<'..altId..'></'..altId..'>'}
   for i=1,columnCount do
      local tagName = columnNode[i].name:nodeValue()
      dataNode[1]:append(xml.ELEMENT, tagName)
   end   

   return dataNode
end

--WS SEARCH
function SoapRequest.search(databaseName, xmlSearchNode, removeEmptyTags, username, password, qualifier)

   if removeEmptyTags or isNilOrEmpty(removeEmptyTags) then
      node.removeEmptyChildNode(xmlSearchNode[1])
   end   

   return SoapRequest.searchRequest(databaseName, xmlSearchNode, username, password, qualifier)
end 

function SoapRequest.searchRequest(databaseName, xmlSearchNode, username, password, qualifier)

   local sessionId = SoapBuilder.getSessionId(databaseName, qualifier)

   if isNilOrEmpty(sessionId) then
      sessionId = SoapAuthenticator.login(databaseName, username, password, qualifier)
   end   

   local xmlBody = xml.parse{data = this.getSearchBody(databaseName)}
   local arg0 = xmlBody["soapenv:Envelope"]["soapenv:Body"]["wsc:search"].arg0
   
   arg0.userName:setInner(username)
   if isLive() then
      arg0.sessionId:setInner(tostring(sessionId))
      arg0:remove('password')
   else
      arg0.password:setInner(password)
      arg0:remove('sessionId')
   end

   arg0.criteria:setInner(xmlSearchNode:S())

   return this.makeSoapRequest(xmlBody:S(), SoapRequest.Type.SEARCH, databaseName, username, password, qualifier)
end   

function SoapRequest.getCriteriaViewNode(viewName, userName, qualifier)

   local xmlWsdl, statusCode = SoapRequest.getWsdl{viewName=viewName, userName=userName, qualifier=qualifier}
   local wsdlNode = xml.parse{data=xmlWsdl}
   local xmlns = wsdlNode.definitions.targetNamespace:nodeValue()
   local wsdlCriteriaNode = wsdlNode.definitions.types["xs:schema"]:child("xs:complexType", 3)
   local altIdView = wsdlCriteriaNode["xs:sequence"]["xs:element"].name:nodeValue()
   local criteriaColumns = wsdlCriteriaNode["xs:sequence"]["xs:element"]["xs:complexType"]["xs:sequence"]

   local criteriaRoot = '<'..altIdView..'></'..altIdView..'>'
   local criteriaNode = xml.parse{data=criteriaRoot}

   for i=1,#criteriaColumns do
      local tagName = criteriaColumns[i].name:nodeValue()
      if tagName ~= "Errors" and tagName ~= "Warnings" then
         trace(tagName)
         criteriaNode[1]:append(xml.ELEMENT, tagName)
      end
   end   

   return criteriaNode
end

function SoapRequest.getWsdl(args)

   local viewName, userName, database, requestMethodName, cacheKey, qualifier
   local isViewBased = true

   -- Collecting values from arguments
   if table.containsKey(args, "viewName") then 

      viewName = args.viewName 

      if table.containsKey(args, "userName") then 
         userName = args.userName 
      else
         userName = "system" 
      end

      if table.containsKey(args, "database") then 
         database = args.database
      else
         database = "meta"
      end  
      qualifier = database
      
      cacheKey = "wsdl&"..viewName.."&"..userName.."&"..database

   elseif table.containsKey(args, "requestMethodName") then

      requestMethodName = args.requestMethodName 
      if table.containsKey(args, "database") then 
         database = args.database 
         qualifier = database
      else
         return ""
      end
      isViewBased = false
      cacheKey = requestMethodName.."&"..database
      
   else
      return ""
   end

   if table.containsKey(args, "qualifier") then
      qualifier = args.qualifier
   end
   
   local environmentName = EnvironmentProperties.getEnvironmentName(qualifier)
   local hostName = EnvironmentProperties.getHostName(qualifier)
   local protocol = EnvironmentProperties.getProtocol(qualifier)

   --Return cached WSDL string
   local result, httpCode, header
   result = Cache.get(cacheKey)
   if false and not isNilOrEmpty(result) then 
      return result
   end

   local endPointUrl = protocol.."://"..hostName.."/"..environmentName.."/meta/wsdl?"

   if isNilOrEmpty(viewName) then
      endPointUrl = endPointUrl.."webService="..string.Capitalize(database).."WebService"
   else
      endPointUrl = endPointUrl.."viewName="..viewName.."&userName="..userName
   end   
   trace(endPointUrl)

   result, httpCode, header = net.http.get{url = endPointUrl, headers = SoapBuilder.getHeader(qualifier), live = true}

   SoapResponse.validateHttpReturnStatus(httpCode, endPointUrl, '', result)

   --Store in the cache
   Cache.put(cacheKey, result)

   return result
end

function SoapRequest.wakeUpQueueRequest(queueName)

   local wakeUpQueueRequest = string.format([[<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
      <Body>
      <wakeUpQueue xmlns="wsclient.msg.tecsys.com">
      <queueName xmlns="">%s</queueName>
      </wakeUpQueue>
      </Body>
      </Envelope>]], queueName)

   local endPointUrl = SoapProperties.getMsgEndpointUrl() 
   local success, errorInfo = pcall(
      function()
         local soapResponse, soapCode = net.http.post{
            url = endPointUrl, headers = SoapBuilder.getHeader("Msg"), body = wakeUpQueueRequest, live = isLive()}
      end
   )
   if not success then
      Logger.logError({Message = 'Failed to wake up queue.\n'..endPointUrl, ErrorInfo = errorInfo, code = soapCode})
   end
end


function this.makeSoapRequest(xmlBody, reqType, databaseName, username, password, qualifier)

   local xmlResponse
   local refreshSessionId = false

   local endPointUrl = SoapProperties.getEndpointUrl(databaseName, qualifier)
   local header = SoapBuilder.getHeader(qualifier)
   local doRun = isLive() or reqType == SoapRequest.Type.SEARCH

   if doRun then

      local result, httpCode
      local success, errorInfo = pcall(
         function()
            result, httpCode = net.http.post{url = endPointUrl, headers = header, body = xmlBody, live = doRun, timeout = HTTP_TIMEOUT}
         end
      )
      if not success then
         Logger.logError({Message="Webservice failed.\n"..str(errorInfo), EndpointUrl=endPointUrl, Request=xmlBody})
      end
      
      SoapResponse.validateHttpReturnStatus(httpCode, endPointUrl, xmlBody, result)

      --W/S error
      xmlResponse = xml.parse{data = result}
      if not SoapResponse.isResponseSuccessful(xmlResponse) then

         if SoapResponse.isInvalidAccessToken(xmlResponse) then
            refreshSessionId = true --retry
         else   
            Logger.logError({Message = 'Webservice failed.', 
               Endpoint = endPointUrl, Response = xmlResponse:S(), Request = xmlBody})
         end   
      end

      --Retry wiith a new session ID
      if refreshSessionId then 
         local reqBody = xml.parse{data=xmlBody}
         local sessionId = SoapAuthenticator.login(databaseName, username, password, qualifier)
         reqBody["soapenv:Envelope"]["soapenv:Body"][1].arg0.sessionId:setInner(sessionId)
         Logger.logInfo('Access token is invalid. Re-trying the request with a new session id '..sessionId)

         result, httpCode = net.http.post{url = endPointUrl, headers = header, body = reqBody:S(), live = doRun, timeout = HTTP_TIMEOUT}
         SoapResponse.validateHttpReturnStatus(httpCode, endPointUrl, xmlBody, result)

         xmlResponse = xml.parse{data = result}

         --W/S error
         if not SoapResponse.isResponseSuccessful(xmlResponse) then
            Logger.logError({Message = 'Webservice failed with a new session id.', 
               Endpoint = endPointUrl, Response = xmlResponse:S(), Request = reqBody:S()})
         end            
      end

      Logger.logSoap(xmlBody..'\n\n'..xmlResponse:S())
   end
   
   return xmlResponse
end  

function this.getUpdateBody(databaseName)

   local wsc = 'wsclient.'..databaseName ..'.tecsys.com'
   local firstLine = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsc=\"'..wsc..'\">'
   local body = firstLine..[==[
   <soapenv:Header/>
   <soapenv:Body>
   <wsc:update>
   <arg0>
   <userName></userName>
   <sessionId></sessionId>
   </arg0>
   </wsc:update>
   </soapenv:Body>
   </soapenv:Envelope>]==]

   return body
end

function this.getSearchBody(databaseName)

   local wsc = 'wsclient.'..databaseName ..'.tecsys.com'
   local firstLine = '<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:wsc=\"'..wsc..'\">'
   local body = firstLine..[==[
   <soapenv:Header/>
   <soapenv:Body>
   <wsc:search>
   <arg0>
   <userName></userName>
   <sessionId></sessionId>
   <password></password>
   <criteria></criteria>
   </arg0>
   </wsc:search>
   </soapenv:Body>
   </soapenv:Envelope>]==]

   return body
end

function SoapRequest.getCriteriaXml(alternateId, xmlTagValueTable)
   -- Returns criteria xml node
   --[[
   <criteria>
   <viewAlternateId>
   <field1></field1>
   <field2></field2>
   </viewAlternateId>
   </criteria>
   ]]

   local criteriaRoot = xml.parse{data='<criteria></criteria>'}
   local criteriaNode = criteriaRoot["criteria"]
   local searchViewNode = criteriaNode:append(xml.ELEMENT, alternateId)

   for tag, value in pairs(xmlTagValueTable) do 
      searchViewNode:append(xml.ELEMENT,tag):setInner(value)
   end

   return criteriaRoot, searchViewNode
end   

function SoapRequest.bulidBatchTransactionRequest(databaseName, dataNode, qualifier)

   local username = SoapProperties.getUsername(qualifier)
   local sessionId = SoapBuilder.getSessionId(databaseName, qualifier)

   if isNilOrEmpty(sessionId) then
      sessionId = SoapAuthenticator.login(databaseName, username, SoapProperties.getPassword(qualifier), qualifier)
   end

   local xmlBody = xml.parse{data = this.getUpdateBody(databaseName)}
   local arg0 = xmlBody["soapenv:Envelope"]["soapenv:Body"]["wsc:update"].arg0
   arg0.userName:setInner(username)
   arg0.sessionId:setInner(sessionId)
   local dataNode = arg0:append(xml.ELEMENT, "transactions"):setInner(dataNode:S())

   return xmlBody:S()
end

function SoapRequest.getXsd(args)

   local viewName, userName, cacheKey, database, qualifier
   
   -- Collecting values from arguments
   if table.containsKey(args, "viewName") then 

      viewName = args.viewName 

      if table.containsKey(args, "userName") then 
         userName = args.userName 
      else
         userName = "system" 
      end

      if table.containsKey(args, "database") then 
         database = args.database
      else
         database = "meta"
      end  
      cacheKey = "xsd&"..viewName.."&"..userName.."&"..database
      qualifier = database

   else
      return ""
   end
   
   if table.containsKey(args, "qualifier") then
      qualifier = args.qualifier
   end
   
   local environmentName = EnvironmentProperties.getEnvironmentName(qualifier)
   local hostName = EnvironmentProperties.getHostName(qualifier)
   local protocol = EnvironmentProperties.getProtocol(qualifier) 

   --Return cached XSD string
   local httpCode, header
   local result = Cache.get(cacheKey)
   if not isNilOrEmpty(result) then 
      return result
   end

   local endPointUrl = "%s://%s/%s/meta/wsdl?viewName=%s&userName=%s&type=xsd"
   endPointUrl = endPointUrl:format(protocol, hostName, environmentName, viewName, userName)

   result, httpCode, header = net.http.get{url = endPointUrl, headers = SoapBuilder.getHeader(qualifier), live = true}
   SoapResponse.validateHttpReturnStatus(httpCode, endPointUrl, '', result)

   if not result:startWith('<?xml version') then 
      Logger.logError({Message = 'Failed to get xsd.', Url = endPointUrl, HttpResult = result})
   end
   
   Cache.put(cacheKey, result)

   return result
end
  

return SoapRequest
