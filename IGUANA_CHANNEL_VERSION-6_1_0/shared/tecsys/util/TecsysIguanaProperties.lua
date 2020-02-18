-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.Util'

local this = {}
local array = {}

TecsysIguanaProperties = {}
local interfaceConnection, lastRefreshed = nil, '1900-01-01 00:00:00'
local propertyTablename = os.getenv('InterfacePropertiesTable')

function this.getPropertyValue(key)

   TecsysIguanaProperties.loadData(false)
   
   local value = array[key:lower()]
   if value == 'NULL' then
      return ""
   end
   
   return value
end

function TecsysIguanaProperties.loadData(refresh)

   trace(interfaceConnection)
   interfaceConnection = TecsysIguanaProperties.getConnection()

   local query = 'select max(mod_stamp) as modStamp from '..propertyTablename
   local modStamp = interfaceConnection:query(query)[1].modStamp:nodeValue()

   if isNilOrEmpty(array) or refresh or lastRefreshed < modStamp then

      iguana.logDebug('lastRefreshed = '..lastRefreshed..', modStamp = '..modStamp)
      array = {}

      local props = interfaceConnection:query('select * from '..propertyTablename)
      for i = 1, #props do
         array[props[i].env_att_key:trimWS()] = props[i].env_att_value:trimWS()
      end

      lastRefreshed = modStamp
      iguana.logDebug('Properties refreshed')
   end
   
   trace(array)
end


function TecsysIguanaProperties.getConnection()

   local connection

   if interfaceConnection ~= nil and interfaceConnection:check() then
      return interfaceConnection
   end
   
   local schema = os.getenv('InterfacePropertiesSchema')
   local api = nil   

   if os.getenv('InterfaceDataSourceVendor') == 'sqlserver' then
      api = db.SQL_SERVER
   else
      api = db.ORACLE_ODBC
   end

   local success, errorInfo = pcall(
      function()
         connection = db.connect{api = api, name = os.getenv('InterfaceDataSource'), 
            user = os.getenv('InterfaceDatabaseUsername'), 
            password = EnvironmentUtil.getPtp(os.getenv('InterfaceDatabasePassword')), 
            use_unicode = true, live = true}
      end
   )

   if not success then
      error({errorInfo, source = debug.getinfo(errorIndex).source, method = debug.getinfo(errorIndex).name, 
            line = debug.getinfo(errorIndex).currentline, callstack = debug.traceback()})
   end

   success, errorInfo = pcall(
      function()
         if api == db.ORACLE_ODBC then
            connection:execute{sql = string.format('ALTER SESSION SET CURRENT_SCHEMA = %s ;', schema), live = true} 
         else
            connection:execute{sql = string.format('use %s', schema), live = true}
         end
      end
   )

   if not success then
      error({errorInfo, source = debug.getinfo(errorIndex).source, method = debug.getinfo(errorIndex).name, 
            line = debug.getinfo(errorIndex).currentline, callstack = debug.traceback()})
   end

   return connection
end

function TecsysIguanaProperties.getPropertyValue(pattern, qualifier, default)

   if isNilOrEmpty(qualifier) then qualifier = '' end
   local propertyValue = this.getPropertyValue(string.format(pattern, qualifier))

   if not isNilOrEmpty(propertyValue) then
      propertyValue = TecsysIguanaProperties.resolvePlaceHolder(propertyValue)
   else
      if isNilOrEmpty(default) then default = 'default' end
      propertyValue =  this.getPropertyValue(string.format(pattern, "default"))

      if propertyValue == nil then
         Logger.logError(string.format(pattern, "default")..' is not defined in Interface Properties table.')
      end 

      propertyValue = TecsysIguanaProperties.resolvePlaceHolder(propertyValue)
   end

   return propertyValue
end

function TecsysIguanaProperties.resolvePlaceHolder(value)

   for currHolder in value:gmatch("{[%a.-]+}") do 
      local currValue = TecsysIguanaProperties.getPropertyValue(currHolder:match('{(.*)}'))
      value = value:gsub(currHolder, currValue)
   end
   
   local propkey = value:match('.*{(.*)}.*')
   if  isNilOrEmpty(propkey) then return value end   

   return TecsysIguanaProperties.resolvePlaceHolder(value)
end
