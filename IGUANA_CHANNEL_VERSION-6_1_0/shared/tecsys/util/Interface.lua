-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

local Retry = require 'retry'
local FileUtil = require 'tecsys.util.FileUtil'
local Csv = require 'tecsys.util.Csv'
local Staging = require 'tecsys.util.Staging'
local Cache = require 'tecsys.util.Cache'
SoapRequest = require 'tecsys.soap.SoapRequest'

local Interface = {}
local this ={}

local NEXT_SEG_SEQ = 'NextSegmentSeq'
local LAST_SEG_SEQ = 'LastSegmentSeq'
local FILENAME = 'Filename'

Interface.SourceType = {['LOCAL']='LOCAL', ['FTP']='FTP', ['SFTP']='SFTP', ['FTPS']='FTPS'}
Interface.FileExt = {['xml']='xml', ['csv']='csv'} --, ['edi']='edi'}
Interface.MinFileAge = 5 --second
Interface.useSoap = true -- false means use ODBC to insert staging records
Interface.username = EnvironmentProperties.getUsername()
Interface.password = EnvironmentProperties.getPassword()
Interface.segmentSize = 100 --records
Interface.BLANK = ""

local SLEEP_INTERVAL = 5000 -- 5 sec
local RETRY_MAX = 2160 -- 3 hours retrying (= 5 sec * 2160)

local xmlTemplates = {}

function Interface.processStagingRequest(database, xmlData)
   -- Send W/S request to create staging usage order
   local xmlResponse, responseStatus = SoapRequest.updateRequest(
      SoapRequest.Action.Create, database, xmlData, 
      Interface.username, EnvironmentProperties.getMiPassword(database))   

   if not SoapResponse.isTransactionSuccessful(xmlResponse) then
      Logger.logError({message = getMessageUrl()..'\n'..xmlResponse:S(), code = responseStatus.code[1]:S()})
   end 
end 

function Interface.getXmlTemplate(viewname, username, database, altId, qualifier)
   
   local templateKey = viewname..'~'..username..'~'..database
   if not isNilOrEmpty(xmlTemplates[templateKey]) then
      return xmlTemplates[templateKey]
   end   

   local xsd = SoapRequest.getXsd{viewName=viewname, userName=username, database=database, qualifier=qualifier}
   local xsdNode = xml.parse{data=xsd}
   local elements = xsdNode["xs:schema"]["xs:element"]["xs:complexType"]["xs:sequence"]; trace(elements)

   --Remove nested chilid if any
   for i= elements:childCount("xs:element"), 1, -1 do
      trace(elements:child("xs:element", i))
      if elements:child("xs:element", i):getChild("xs:complexType") then
         elements:remove(i)
      end   
   end 

   local templateValue = elements:S():gsub('xs:element name="', '')
      :gsub('" minOccurs="0"></xs:element', '/'):gsub('xs:sequence',altId)
   
   xmlTemplates[templateKey] = templateValue
   
   return templateValue
end 

function Interface.getXmlTagRegEx(tag)
   -- Returns two regular expressions that matches open and close xml tag
   return '%s*<%s*'..tag..'%s*>%s*', '%s*<%s*/%s*'..tag..'%s*>%s*'
end 

function Interface.initialize()
   if not isLive() then 
      errorIndex = 2 
   end

   throw=error
   iguana.stopOnError(false)
   iguana.setTimeout(RETRY_TIMEOUT)
end

--This function assume that Interface.initialize() or iguana.stopOnError(false) is alerady called 
function Interface.sanityChecks(qualifier)
   if not EnvironmentUtil.isEnvironmenUp(qualifier) then 
      local errorMsg = 'The environment '..EnvironmentProperties.getEnvironmentName(qualifier)..' is not responding.'
      Logger.logError(errorMsg)  
   end
end

function Interface.waitForService(qualifier)
   -- Do not run the channel until the portal is up and running
   -- Wait for the portal to respond for 3 hours. If not, they stop the channel.
   local count = 0

   while count < RETRY_MAX do
      if EnvironmentUtil.isEnvironmenUp(qualifier) then 
         break
      else
         count = count + 1
         local errorMsg = 'The environment '..EnvironmentProperties.getEnvironmentName(qualifier)
            ..' is not responding. Retrying..#'..count
         Logger.logWarning(errorMsg)
         
         if not isLive() then
            return false, errorMsg
         end   
         
         util.sleep(SLEEP_INTERVAL) --wait for 5 sec to ping the portal
      end
   end 
   
   if count >= RETRY_MAX then
      iguana.stopOnError(true)
      Logger.logError('The environment '..EnvironmentProperties.getEnvironmentName()
         ..' has not responded for '..(RETRY_MAX * SLEEP_INTERVAL/60/60/1000)
         ..' hours. Stopping the channel.')
   end   
   
   return true
end

function Interface.validParameter(miModule, data)

   trace(miModule.getMiConfig().entity, data.target)
   if miModule.getMiConfig().entity ~= data.target or isNilOrEmpty(data.path) then 
      return false 
   end

   local valid = true

   if isNilOrEmpty(data.target) then
      Logger.logWarning("The filename contains invalid target. "
         ..filename.." has been moved to the error directory.\n"..Data)
      valid = false

   elseif isNilOrEmpty(Interface.FileExt[data.extension]) then
      Logger.logWarning("The processing file must have valid extension. "
         ..filename.." has been moved to the error directory.\n"..Data)
      valid = false
   end   

   if not valid then
      FileUtil.moveFile(data.path:getBefore(data.filename), 
         SmsProperties.getInboundErrorDatePath(data.target), data.path)
   end   

   return valid, data
end

function Interface.isXml(extension)
   return extension == Interface.FileExt.xml
end

function Interface.isCsv(extension)
   return extension == Interface.FileExt.csv
end

function Interface.process(Data, miModule)

   local valid, data = Interface.validParameter(miModule, Data)
   if not valid then 
      return 
   end

   local extension = data.extension
   local filename = data.filename
   local entity = data.target
   local path = data.path --data.path must NOT be remote path such as FTP, SFTP, ...
   local directoryPath = FileUtil.getDirectoryPath(path)

   local success, errorInfo = pcall(function ()
         if Interface.isXml(extension) then
            success, result = Interface.processXml(path, miModule)

         elseif Interface.isCsv(extension) then -- extension == 'csv' then
            success, result = Interface.processCsv(path, miModule)
         end
      end)

   if success then
      FileUtil.moveFile(directoryPath, SmsProperties.getInboundArchiveDatePath(entity), path)
      
   else
      if FileUtil.fileExists(path) then
         local errorPath = SmsProperties.getInboundErrorDatePath(entity)
         FileUtil.moveFile(directoryPath, errorPath, path)
         Exception.concat(errorInfo, 'File '..filename..' has been moved to the error directory '..errorPath)
      end

      Logger.logError(string:printObject(errorInfo)) 
   end     

end

function Interface.processXml(path, miModule)

   local transaction = FileUtil.getFileContent(path)
   transaction = miModule.preProcess(transaction)
   Interface.processStagingRequest(miModule.getDatabaseName(), xml.parse{data=transaction}.Transactions[1]:S())

end

function Interface.processCsv(path, miModule)

   local csvNode, first, last
   local filename = FileUtil.getFilename(path)

   local transaction = ''
   local recordCounter = 0
   local segmentCounter = 0

   --Process any segment left from the previous transaction due to exception
   local prevFilename = Cache.get(FILENAME)
   if not isNilOrEmpty(prevFilename) then
      Interface.processSegments(prevFilename, Cache.get(NEXT_SEG_SEQ), Cache.get(LAST_SEG_SEQ), miModule)

      if filename == prevFilename then return end
   end

   --Break the input file into multiple segments (100 records per segment)
   --and save them to cache
   for line in io.lines(path) do

      line = line:trimWS()

      if not isNilOrEmpty(line) then

         --This line is for testing only
         if not isLive() and segmentCounter > 2 then break end

         line = line:escape()
         csvNode = Csv.parseCsv(line)
         transaction = transaction..miModule.getXmlForCsv(csvNode)
         recordCounter = recordCounter + 1

         if recordCounter == Interface.segmentSize then
            segmentCounter = Interface.saveSegment(filename, segmentCounter, transaction)
            transaction = ''
            recordCounter = 0
         end
      end   
   end

   if not isNilOrEmpty(transaction) then
      segmentCounter = Interface.saveSegment(filename, segmentCounter, transaction)
   end   

   Cache.put(FILENAME, filename)
   Cache.put(NEXT_SEG_SEQ, 1)
   Cache.put(LAST_SEG_SEQ, segmentCounter)
   Interface.processSegments(filename, 1, segmentCounter, miModule)

end

--Send web service for each segment
function Interface.processSegments(filename, first, last, miModule)

   local success, result

   for i = tonumber(first), tonumber(last) do
      local key = filename..i
      transaction = Cache.get(key)
      
      -- call module extension to enhance transaction data
      transaction = miModule.preProcess(transaction) 

      if isLive() then
         Logger.logSoap('Sending Webservice for segment '..i..'/'..last..' for '..filename)
         local success, errorInfo = pcall(function()
               Interface.processStagingRequest(miModule.getDatabaseName(), transaction)
            end
         )
         if success then 
            Cache.remove(key)
            Cache.put(NEXT_SEG_SEQ, i+1)
         else
            trace('Break out of the loop'); error({message=errorInfo})
         end
      end
   end   

   Cache.remove(FILENAME)
   Cache.removeAll(filename)
end

--Save the current transaction batch/segment to cache
function Interface.saveSegment(filename, segmentCounter, transaction)
   segmentCounter = segmentCounter + 1
   local key = filename..segmentCounter
   Cache.put(key, transaction)
   return segmentCounter
end

-- Declare cache table to reduce db access
tableNameResult = {}
recordNameResult = {}
recordActionResult = {}
viewAltIdResult = {}
colAltIdRresult ={}
colPositionRresult ={}

function Interface.getViewAltId(viewname)

   local database = viewname:sub(1,3)
   local key = database..'-'..viewname..'-viewAltId'
   local viewAltId = colPositionRresult[key]

   if isNilOrEmpty(viewAltId) then

      local query = [[select distinct alt_identifier from md_view 
      where database_name = '%s' and view_name = '%s']]
      query = string.format(query, database, viewname)
      local result = DatabaseConnection.query('meta', query)

      if #result > 0 then
         viewAltId = result[1].ALT_IDENTIFIER:nodeValue()
         viewAltIdResult[key] = viewAltId
      end
   end

   return viewAltId
end

function Interface.getTableName(viewname)

   local database = viewname:sub(1,3)
   local key = database..'-'..viewname..'-tablename'
   local tableName = tableNameResult[key]

   if isNilOrEmpty(tableName) then

      local query = [[select distinct table_name from md_view 
      where database_name = '%s' and view_name = '%s']]
      query = string.format(query, database, viewname)
      local result = DatabaseConnection.query('meta', query)

      if #result > 0 then
         tableName = result[1].TABLE_NAME:nodeValue()
         tableNameResult[key] = tableName
      end
   end

   return tableName
end

function Interface.getRecordName(mdImport, viewname)

   local key = mdImport..'-'..viewname..'-recordName'
   local recordName = recordNameResult[key]

   if isNilOrEmpty(recordName) then

      local query = [[select distinct record_name from md_import_record 
      where view_name = '%s' and import_name = '%s']]
      query = string.format(query, viewname, mdImport)
      local result = DatabaseConnection.query('meta', query)

      if #result > 0 then
         recordName = result[1].RECORD_NAME:nodeValue()
         recordNameResult[key] = recordName
      end
   end

   return recordName
end

function Interface.getRecordAction(mdImport, database)

   local key = mdImport..'-recordAction'
   local recordAction = recordActionResult[key]

   if isNilOrEmpty(recordAction) then

      local query = [[select distinct record_action from md_import 
      where import_name = '%s' and database_name = '%s']]
      query = string.format(query, mdImport, database)
      local result = DatabaseConnection.query('meta', query)

      if #result > 0 then
         recordAction = result[1].RECORD_ACTION:nodeValue()
         recordActionResult[key] = recordAction
      end
   end

   return recordAction
end
-----------------------------------
--XML DB Utils
-----------------------------------
function Interface.getColumnAltId(database, table)
   --Get physical column and its AltId for a given db/table
   local query = [[select alt_identifier, column_name from md_column 
   where database_name = '%s' and column_type = 1 and table_name = '%s']]
   query = string.format(query, database, table)

   return DatabaseConnection.query('meta', query)
end  

function Interface.mapXmlToTable(database, table, row, node)
   local key = database..'~'..table..'~xml'

   local result = colAltIdRresult[key]
   if isNilOrEmpty(result) then
      result = Interface.getColumnAltId(database, table)
      colAltIdRresult[key] = result
   end

   trace(#result)
   for i = 1, #result do
      local altId = result[i][1]:S()
      if node:hasChild(altId) then
         row[result[i][2]:S()]=node[altId]:nodeText()
      end  
   end

   return row
end  

-----------------------------------
--CSV DB Utils
-----------------------------------
function Interface.getMdImportRecordField(mdImport, database, recordName)
   --Get physical column and its AltId for a given db/table
   local sql = [[select f.field_position, f.column_name, c.alt_identifier  
   from md_import h, md_import_record r, md_import_record_field f, md_column c
   where h.database_name = r.database_name and h.import_name = r.import_name 
   and r.database_name = f.database_name and r.import_name = f.import_name and r.record_name = f.record_name
   and f.database_name = c.database_name and f.table_name = c.table_name and f.column_name = c.column_name
   and h.database_name = '%s'
   and h.import_name = '%s'
   and h.instance_name = 'tecsys_default' ]]..
   iif(isNilOrEmpty(recordName), '', "and r.record_name = '%s'")..
   [[ order by f.field_position asc]]

   sql = string.format(sql, database, mdImport, recordName)
   local result = DatabaseConnection.query('meta', sql)
   return result
end  

function Interface.mapCsvToXml(mdImport, database, table, csvNode, recordName)

   local output = ''
   local key = database..'~'..table..'~xml'

   local result = colPositionRresult[key]
   if isNilOrEmpty(result) then
      result = Interface.getMdImportRecordField(mdImport, database, recordName)
      colPositionRresult[key] = result
   end

   trace(result)
   local value, columnName
   for i = 1, #result do
      local altID = result[i].ALT_IDENTIFIER:S()
      value = csvNode[1][tonumber(result[i].FIELD_POSITION:S())]
      if not isNilOrEmpty(value) then
         output = output.."<"..altID.."><![CDATA["..value.."]]></"..altID..">\n"
      end
   end

   return output   
end

function Interface.mapCsvToTable(mdImport, database, table, row, csvNode, recordName)
   local key = database..'~'..table..'~csv'

   local result = colPositionRresult[key]
   if isNilOrEmpty(result) then
      result = Interface.getMdImportRecordField(mdImport, database, recordName)
      colPositionRresult[key] = result
   end

   trace(#result)
   local value, columnName
   for i = 1, #result do
      columnName = result[i].COLUMN_NAME:S()
      value = csvNode[1][tonumber(result[i].FIELD_POSITION:S())]
      if not isNilOrEmpty(value) then
         row[columnName] = value
      end
   end

   return row
end 

function Interface.getNewInterfaceBatch(interfaceBatch)
   return interfaceBatch.."-"..os.date('%Y%m%d%H%M%S')
end

function Interface.writeXml(xmlContent, outputPath)

   local success, errorInfo = pcall(function()
         if isLive() then
            local file = io.open(outputPath, "w")
            file:write(xmlContent)
            file:close()
            Logger.logInfo('Created '..outputPath)
         end   
      end
   )
   return success, errorInfo
end

function Interface.writeCsv(xmlContent, outputPath)

   local success, errorInfo = pcall(function()
         local dataNode = xml.parse{data=xmlContent}
         local recLine = ''

         for i = 1, dataNode[1]:childCount() do
            local record = dataNode[1][i]
            local recTable = {}

            for j = 1, record:childCount() do
               recTable[j] = record[j]:nodeText()
            end   

            recLine = recLine..table.getDelimitedList(recTable, ',')..'\n'
         end  

         trace(recLine)

         if isLive() then
            local file = io.open(outputPath, "w")
            file:write(recLine)
            file:close()
            Logger.logInfo('Created '..outputPath)
         end   
      end
   )
   return success, errorInfo
end

function Interface.getTemplateNode(databaseName, viewname, groupXmlTag)
   local headerXmlTag = Interface.getViewAltId(viewname)
   local headerXml = Interface.getXmlTemplate(
      viewname, Interface.username, databaseName, groupXmlTag)
   local headerXmlNode = xml.parse{data = headerXml}
   return headerXmlNode[groupXmlTag]
end

return Interface