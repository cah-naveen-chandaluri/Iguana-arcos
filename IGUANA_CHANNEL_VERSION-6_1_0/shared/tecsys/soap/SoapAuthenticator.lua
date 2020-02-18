-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.soap.SoapProperties'
require 'tecsys.soap.SoapBuilder'
require 'tecsys.util.StringUtil'

SoapAuthenticator = {}

function SoapAuthenticator.login(databaseName, username, password, qualifier)

   assert(not isNilOrEmpty(databaseName), 'databaseName is required!')
   assert(not isNilOrEmpty(username), 'username is required!')
   assert(not isNilOrEmpty(password), 'password is required!')
   
   if isNilOrEmpty(qualifier) then qualifier = "" end
   
   local loginResponse, loginResponseXml, loginResponseStatus, sessionId
   local loginBodyTemplate = [[<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wsc="wsclient.]]..databaseName..[[.tecsys.com">
   <soapenv:Header/>
   <soapenv:Body>
      <wsc:login>
         <arg0>
            <userName></userName>
            <password></password>
         </arg0>
      </wsc:login>
   </soapenv:Body>
   </soapenv:Envelope>]]
   
   local loginBody = xml.parse{data = loginBodyTemplate}
   
   local username = SoapProperties.getUsername(qualifier)
   local password = SoapProperties.getPassword(qualifier)
   loginBody["soapenv:Envelope"]["soapenv:Body"]["wsc:login"].arg0.userName:setInner(username)
   loginBody["soapenv:Envelope"]["soapenv:Body"]["wsc:login"].arg0.password:setInner(password)
   
   trace(loginBody:S())
   
   if isLive() then
      
      success, errorInfo = pcall(
         function()
            loginResponse = net.http.post{url = SoapProperties.getEndpointUrl(databaseName, qualifier), 
               headers = SoapBuilder.getHeader(qualifier), body = loginBody:S(), live = true}
            loginResponseXml = xml.parse{data = loginResponse}
            loginResponseStatus = loginResponseXml["soap:Envelope"]["soap:Body"]["ns2:loginResponse"]["return"]["status"]
         end
      )
      
      if not success then
         Logger.logError(errorInfo)
      end
      
      if not loginResponseStatus.code[1]:S():equals("0") then
         Logger.logError({message = loginResponseStatus.description[1]:S(), code = loginResponseStatus.code[1]:S()})
      end
      
      sessionId = loginResponseXml[1][2][1][2][1][1]:nodeValue()
      SoapBuilder.setSessionId(databaseName, sessionId, qualifier)
      
      return sessionId
   end   
   
   return "DEBUG-SESSIONID"
end

function SoapAuthenticator.getSessionkeyQualifier(databaseName, qualifier)
   
   assert(not isNilOrEmpty(databaseName), 'databaseName is required!')
   
   if isNilOrEmpty(qualifier) then qualifier = '' end
   
   return databaseName..'@'..qualifier
end   