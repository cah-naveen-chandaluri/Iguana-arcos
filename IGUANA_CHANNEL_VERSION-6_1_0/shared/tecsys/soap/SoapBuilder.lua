-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.EnvironmentProperties'
require 'tecsys.util.StringUtil'
require 'tecsys.util.Util'

SoapBuilder = {}
local this = {}

function SoapBuilder.getSessionId(databaseName, qualifier)

   assert(not isNilOrEmpty(databaseName), 'databaseName is required!')
   if isNilOrEmpty(qualifier) then qualifier = '' end

   local sessionId = nil
   local success, errorInfo = pcall(
      function()
         local keyName = string.format('tecsys.soap-web-services.%s.public_session', SoapAuthenticator.getSessionkeyQualifier(databaseName, qualifier))
         local connection = this.getConnection()
         this.createTableProperties(connection)
         sessionId = connection:query{sql = string.format("select value from properties where key=%q", keyName:lower()), live = true}
         connection:close()
      end
   )

   if not success or sessionId == nil then
      Logger.logError(errorInfo)
   end

   if sessionId[1]:S():equals("NULL") then
      return nil
   end

   return sessionId[1].value:nodeValue()
end

function SoapBuilder.setSessionId(databaseName, sessionId, qualifier)

   assert(not isNilOrEmpty(databaseName), 'databaseName is required!')
   assert(not isNilOrEmpty(sessionId), 'sessionId is required!')

   if isNilOrEmpty(qualifier) then qualifier = '' end

   local success, errorInfo = pcall(
      function()
         local keyName = string.format('tecsys.soap-web-services.%s.public_session', SoapAuthenticator.getSessionkeyQualifier(databaseName, qualifier))
         local connection = this.getConnection()

         --update
         if not isNilOrEmpty(SoapBuilder.getSessionId(databaseName, qualifier)) then
            connection:execute{sql = string.format("update properties set value=%q where key=%q", sessionId, keyName), live = true}
            --insert
         else
            connection:execute{sql = string.format("insert into properties values (%q,%q)", keyName, sessionId), live = true}
         end  
         connection:close()
      end
   )

   if not success then
      Logger.logError(errorInfo)
   end
end

function SoapBuilder.getHeader(qualifier)

   local hostname = EnvironmentProperties.getHostName(qualifier)
   local header = {['Content-Type']='text/xml; charset=UTF-8',
      SOAPAction = "",
      Connection = "Keep-Alive",
      ['User-Agent'] = "Tecsys",
      Host = hostname}

   return header
end

function this.createTableProperties(connection)

   success, errorInfo = pcall(
      function()
         connection:execute{sql = "CREATE TABLE IF NOT EXISTS properties (key TEXT(255) NOT NULL PRIMARY KEY, value TEXT(255) NULL)", live = true}
      end
   )

   if not success then
      Logger.logError(errorInfo)
   end
end

function this.getConnection()

   local connection
   success, errorInfo = pcall(
      function()
         local databaseName = "TecsysIguana.sqlite"
         connection = db.connect{api = db.SQLITE, name = databaseName, live = true}
      end
   )

   if not success then
      Logger.logError(errorInfo)
   end

   return connection
end