-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local FileUtil = require "tecsys.util.FileUtil"
local FtpUtil = require "tecsys.util.FtpUtil"
Interface = Interface or require "tecsys.util.Interface"
local Validation = require "cardinal.util.Validation"
local WinExitCodes = require "tecsys.util.WinExitCodes"

local Util = {}
local this = {}
local viewAltIds = {}

function Util.isEliteOrder(filename)
   return not isNilOrEmpty(filename:find("_po_"))
end   

function Util.isCsosOrder(filename)
   return not isNilOrEmpty(filename:find("_co_"))
end 

function Util.getOrganizationCode()
   local orgCode = iguana.channelName():split("-")[1]
   return iif (orgCode:len() == 2 or orgCode:upper() == 'ORG', orgCode:upper(), nil)
end

function this.doPost(sessionId, orgCode)
   
   local endPointUrl = SoapProperties.getMsgEndpointUrl('DmsWebService') 
   local soapReqTemplate = [[<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
    <soapenv:Body>
        <wsc:customerMassUpdate xmlns:wsc="wsclient.dms.tecsys.com">
            <arg0>
                <userName>%s</userName>
                <sessionId>%s</sessionId>
                <orgCode>%s</orgCode>
            </arg0>
        </wsc:customerMassUpdate>
    </soapenv:Body>
</soapenv:Envelope>]]
   local soapReq = string.format(soapReqTemplate, EnvironmentProperties.getUsername(), sessionId, orgCode)

   local soapResponse, soapCode = net.http.post{
      url = endPointUrl, headers = SoapBuilder.getHeader(), body = soapReq, live = isLive()}

   if not HTTPCODE.isSuccess(soapCode) then
      Logger.logError({message = soapResponse, soapRequest = soapReq, code = soapCode})
   end

   return soapResponse, soapCode, soapReq
end

function Util.runCustomerMassUpdate(orgCode)

   local sessionId = SoapBuilder.getSessionId('dms')
   
   if isNilOrEmpty(sessionId) then
      sessionId = SoapAuthenticator.login('dms', EnvironmentProperties.getUsername(), EnvironmentProperties.getPassword())
   end

   local soapResponse, soapCode, soapRequest = this.doPost(sessionId, orgCode)
   
   if SoapResponse.isInvalidAccessToken(soapResponse, reqType) then
      local sessionId = SoapAuthenticator.login('dms', EnvironmentProperties.getUsername(), EnvironmentProperties.getPassword())
      soapResponse, soapCode, soapRequest = this.doPost(sessionId, orgCode)
   end   

   if not isLive() then return true, "DEBUG" end

   local resNode = xml.parse{data=soapResponse}
	Logger.logSoap('Soap return code: ' .. soapCode .. ' /n ' .. resNode:S())

   local returnData = resNode["soap:Envelope"]["soap:Body"]["ns2:customerMassUpdateResponse"]["return"]
   local rejected = tonumber(returnData.totalRecordRejected:nodeText())
   
   --Build waring messages if any
   local warningMsg = ""
   for i = 1, returnData:childCount("warning") do
      warningMsg = warningMsg..returnData:child("warning", i):nodeText().."\n" 
   end   

   if rejected > 0 or not isNilOrEmpty(returnData:getChild('error')) then 
      Logger.logSoap({Message="SOAP customerMassUpdateResponse(CUCIMPB1)"
            , EndpointUrl=SoapProperties.getMsgEndpointUrl('DmsWebService'), Request=soapRequest, Response=resNode:S()})
      
      return false, resNode:S() --error message
   end

   return true, warningMsg --warning message
end

function Util.getLogMsg(recordId, filename, status, errMsg)
   if errMsg == nil then errMsg = "" end
   
   return string.format("%s\n\nRecord Id:%s\nFilename:%s\nStatus:%s\n\nError:\n%s"
      ,this.getUrlToDetailsPage(recordId), recordId, filename, Status.index(status), errMsg)
end

function this.getUrlToDetailsPage(recordId)
   local envName = EnvironmentProperties.getEnvironmentName(INTERFACE_QUALIFIER)
   local host = EnvironmentProperties.getHostName(INTERFACE_QUALIFIER)
   local protocol = EnvironmentProperties.getProtocol(INTERFACE_QUALIFIER)
   
   return  protocol..'://'..host..'/'..envName..
   '/portal/home?criteriaMuid=meta%7Cinterface_file_ce%7C'..
   recordId..'&resourceName_1=meta_interface_file_ce&goToDetail=1'   
end 

function Util.getMapper(filename)
   
   local mapperNode
   local success, errorInfo = pcall(
      function ()
         local filePath = os.fs.abspath(iguana.project.root()..'/other/map/'..filename)
         mapperNode = json.parse{data=FileUtil.getFileContent(filePath)}
      end
   )

   if not success then
      Logger.logError({'Failed to retrieve a mapper file '..filename, errorInfo})
   end

   return mapperNode
end

function Util.getTemplate(filename)

   local tplNode
   local success, errorInfo = pcall(
      function ()
         local filePath = os.fs.abspath(iguana.project.root()..'/other/template/'..filename)

         if FileUtil.getExtension(filename) == 'json' then
            tplNode =  json.parse{data=FileUtil.getFileContent(filePath)}
         else
            tplNode =  xml.parse{data=FileUtil.getFileContent(filePath)}
         end
      end
   )

   if not success then
      Logger.logError({'Failed to retrieve a template file '..filename, errorInfo})
   end

   return tplNode   
end

function Util.getXsd(filename)
   
   local content
   local success, errorInfo = pcall(
      function ()
         local filePath = os.fs.abspath(iguana.project.root()..'/other/cardinal/xsd/'..filename)
         content =  FileUtil.getFileContent(filePath)
      end
   )

   if not success then
      Logger.logError({'Failed to retrieve a xsd file '..filename, errorInfo})
   end

   return content   
end

function Util.getSql(filename)

   local content
   local success, errorInfo = pcall(
      function ()
         local filePath = os.fs.abspath(iguana.project.root()..'/other/cardinal/sql/'..filename)
         content =  FileUtil.getFileContent(filePath)
      end
   )

   if not success then
      Logger.logError({'Failed to retrieve a sql file '..filename, errorInfo})
   end

   return content      
end

function Util.mapXmlToDb(mapper, row, dataTree)
   
   for k, v in pairs(mapper) do
      trace(k,v)
      if not isNilOrEmpty(v) and k ~= "_comment" then  --Do not process comment(s)
         local childNode = dataTree:getNodeByPath(v:split("/"))
         if not isNilOrEmpty(childNode) then
            trace('row['..k..'] = '..childNode:nodeText())
            row[k] = childNode:nodeText()
         end   
      end   
   end
   
   return row
end  

function Util.decompress(filePath, destPath)

   local ExitCodes = {
      [0] = 'No error',
      [1] = 'Warning (Non fatal error(s)). For example, one or more files were locked by some other application, so they were not compressed.',
      [2] = 'Fatal error',
      [7] = 'Command line error',
      [8] = 'Not enough memory for operation',
      [255] = 'User stopped the process'
   }   
   
   local function removeTempFolder(destPath)
      --Remove the existing directory
      if FileUtil.dirExists(destPath) then
         if isLive() then
            FileUtil.removeDirctory(destPath) --remove
         else
            return
         end
      end   
   end   

   removeTempFolder(destPath)
   
   local extractCmd = '"C:\\Program Files\\7-Zip\\7z"'
   local fileDirPath = FileUtil.getDirectoryPath(filePath)
   local nativeFilePath =  os.fs.name.toNative(filePath)
   local nativeDestPath =  os.fs.name.toNative(destPath)

   local success, errorInfo = pcall(
      function()
         local command 
         if not isNilOrEmpty(destPath) then
            command = string.format(extractCmd.." e %s -o%s", nativeFilePath, nativeDestPath)
         else
            command = string.format(extractCmd.." e %q", nativeFilePath)
         end

         local exitVal = os.execute(command)
         if exitVal > 0 then
            removeTempFolder(destPath)
            error('Failed to decompress the file. Exit code#: '..exitVal..' : '..ExitCodes[exitVal])
         end
      end
   )

   if not success then
      Logger.logError(errorInfo)
   end   
end

function Util.getFileList(sourceType, sourecPath)

   if sourceType == Interface.SourceType.LOCAL then
      -- Read all(*) filenames with the default fileage = 5 sec
      return FileUtil.getFileList(sourecPath, "*", Interface.MinFileAge, true)
   end

   local FtpConn = FtpUtil.getConnection(ftpSiteCode)
   return FtpConn:list{remote_path=sourecPath}, FtpConn
end

function Util.getTemplateNode(viewname, database, qualifier)
   local userName = EnvironmentProperties.getUsername(qualifier)
   local groupXmlTag = Util.getViewAltId(viewname, userName, qualifier)
   local headerXml = Interface.getXmlTemplate(
      viewname, userName, database, groupXmlTag, qualifier)
   local headerXmlNode = xml.parse{data = headerXml}
   return headerXmlNode[groupXmlTag]
end

function Util.sendSoapUpdateRequest(xmlData, database, qualifier, action)
   -- Send W/S request to create staging usage order
   local xmlResponse, responseStatus = SoapRequest.updateRequest(
      action, database, xmlData, 
      EnvironmentProperties.getUsername(qualifier), 
      EnvironmentProperties.getPassword(qualifier), qualifier) 
   
   return xmlResponse, responseStatus
end  

function Util.getViewAltId(viewname, userName, qualifier)
   local xmlXsd = SoapRequest.getXsd{viewName=viewname, userName=userName, qualifier=qualifier}
   local xsdNode = xml.parse{data=xmlXsd}
   return xsdNode["xs:schema"]["xs:element"].name:nodeValue()
end

function Util.getOpenTag(tag)
   return '<'.. tag .. '>'
end  

function Util.getCloseTag(tag)
   return '</'.. tag .. '>'
end 

function Util.getEmptyTag(tag)
   return '<'..tag..'></'..tag..'>'
end 
   
function Util.initChannel()
   Validation.checkIguanaEnvVars()
   TecsysIguanaProperties.loadData()
end   

function Util.getNomalizedDate(data)
   
   if isNilOrEmpty(data) then return '' end
   
   local t, d
   if data:match('%d%d%d%d%d%d%d%d') then
      t, d = dateparse.parse(data, 'mmddyyyy')
      return tostring(t)
   elseif data:match('%d%d/%d%d/%d%d%d%d') then  
      t, d = dateparse.parse(data, 'mm/dd/yyyy')
      return tostring(t)
   end   
   
   return data
end
return Util