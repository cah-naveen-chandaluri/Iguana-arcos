-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.db.DatabaseProperties'
require 'tecsys.util.DateUtil'
require 'tecsys.util.StringUtil'
require 'tecsys.util.Util'

local this = {}
DatabaseConnection = {}

local connectionMap = {}
local begunConnectionMap = {}

function DatabaseConnection.commit(dbname)

   local success, errorInfo = pcall(
      function()
         for i=1, #begunConnectionMap do
            if isNilOrEmpty(dbname) or dbname == begunConnectionMap[i][1] then
               begunConnectionMap[i][2]:commit{live=isLive()}
            end   
         end
      end
   )
   
   if not success then
      Logger.logError(errorInfo)
   end
   
   begunConnectionMap = {}
end

function DatabaseConnection.rollback()
   
   local success, errorInfo = pcall(
      function()
         for i=1, #begunConnectionMap do
            begunConnectionMap[i][2]:rollback()
         end
      end
   )
   
   if not success then
      Logger.logError(errorInfo)
   end
   
   begunConnectionMap = {}
end

function DatabaseConnection.isInTransaction()
   if #begunConnectionMap == 0 then
      return false
   end
   
   return true
end   
   
function DatabaseConnection.close()
   
   for i=1, #connectionMap do
      if connectionMap[i][2] and connectionMap[i][2]:check() then
         connectionMap[i][2]:close()
      end
   end
   
   connectionMap = {}
   begunConnectionMap = {}
end

function DatabaseConnection.executeSql(databaseName, sql, qualifier)
   
   if isNilOrEmpty(qualifier) then
      qualifier = 'default'
   end
   
   local connection = this.getBegunConnection(databaseName, qualifier)
   
   local success, errorInfo = pcall(
      function()
         connection:execute{sql = sql, live = isLive()}
      end
   )
   
   if not success then
      Logger.logError({errorInfo, sqldata = sql})
   end
   
   Logger.logSql(sql)
   
end

function DatabaseConnection.query(databaseName, sql, qualifier)
   
   if isNilOrEmpty(qualifier) then
      qualifier = 'default'
   end
   
   local connection = this.getConnection(databaseName, qualifier)
   
   local result
   
   local success, errorInfo = pcall(function()
         result = connection:query{sql = sql, live = true}
      end
   )

   if not success then
      Logger.logError({errorInfo, sqldata = sql})
   end
   
   Logger.logSql(sql)
   
   return result, success
end

function DatabaseConnection.merge(databaseName, data, isRemoveNull, qualifier)

   if isNilOrEmpty(qualifier) then
      qualifier = 'default'
   end
   
   if isRemoveNull then
      for i = 1,#data[1] do
         DatabaseUtil.removeNull(data[1][i])
      end
   end
   trace(data)
   local connection = this.getBegunConnection(databaseName, qualifier)

   local success, errorInfo = pcall(
      function()
         connection:merge{data = data, bulk_insert = false, transaction = false, live = isLive()}
      end
   )
   
   if not success then
      Logger.logError({errorInfo, sqldata = data})
   end
   
   Logger.logSql(data:S())
end

function DatabaseConnection.getCurrentTimestamp(databaseName, qualifier)
   
   local connection = this.getConnection(databaseName, qualifier)
   local result
   
   if this.isSqlServerConnection(connection) then
      result = DatabaseConnection.query(databaseName, "SELECT CURRENT_TIMESTAMP")[1].Column_1:dateTimeParse()
      
   elseif this.isOracleConnection(connection) then
      result = DatabaseConnection.query(databaseName, "SELECT SYSDATE FROM DUAL;")[1].SYSDATE:dateTimeParse()
   end 
   
   return result
end

function DatabaseConnection.getIdentity(databaseName, tableName, qualifier)
   
   local connection = this.getConnection(databaseName, qualifier)
   local result, id
   
   if this.isOracleConnection(qualifier) then
      
      if not isLive() then 
         DatabaseConnection.query(databaseName, string.format('select %s_SRL.NEXTVAL FROM dual;', tableName))
      end
      
      id = DatabaseConnection.query(databaseName, string.format('select %s_SRL.CURRVAL FROM dual;', tableName))
      result = id[1].CURRVAL:S()
      
   elseif this.isSqlServerConnection(qualifier) then
      
      id = DatabaseConnection.query(databaseName, 'SELECT @@IDENTITY')
      result = id[1].Column_1:S()
   end
   
   return tonumber(result)
end

function this.begin(databaseName, qualifier)
   
   local connection = this.getConnection(databaseName, qualifier)
   
   local success, errorInfo = pcall(
      function()
         connection:begin()
      end
   )
   
   if not success then
      Logger.logError(errorInfo)
   end
   
   trace(databaseName)
   trace(connection)
   
   begunConnectionMap[#begunConnectionMap+1] = {databaseName, connection}
end

function this.getBegunConnection(databaseName, qualifier)
   
   for i=1, #begunConnectionMap do
      local conn = begunConnectionMap[i][2]
      if begunConnectionMap[i][1]:equals(databaseName) then
         if conn:check() then
            return conn
         else
            table.remove(begunConnectionMap, i)
         end   
      end
   end
   
   local connection = this.getConnection(databaseName, qualifier)
   this.begin(databaseName, qualifier)
   return connection
end

function this.getConnection(databaseName, qualifier)
    
   local connection

   for i=1, #connectionMap do
      if (not isNilOrEmpty(connectionMap[i])) and connectionMap[i][1]:equals(databaseName) then
         connection = connectionMap[i][2]
         
         if connection:check() == false then
            connection:close()
            table.remove(connectionMap, i)
            connection = nil
         end   
      end
   end
   
   if connection ~= nil and connection:check() then
      return connection
   end

   local username = DatabaseProperties.getUsername(qualifier)
   local password = DatabaseProperties.getPassword(qualifier)
   local dataSourceName = DatabaseProperties.getDataSourceName(qualifier)
   local schema = DatabaseProperties.getSchema(databaseName)
   local api = nil
   
   if DatabaseProperties.isSqlServer(qualifier) then
      api = db.SQL_SERVER
   elseif DatabaseProperties.isOracle(qualifier) then
      api = db.ORACLE_ODBC
   end
   
   local success, errorInfo = pcall(
      function()
         connection = db.connect{api = api, name = dataSourceName, user = username, 
            password = password, use_unicode = true, live = true}
      end
   )
   
   if not success then
      Logger.logError(errorInfo)
   end
   
   success, errorInfo = pcall(
      function()
         if this.isOracleConnection(connection) then
            connection:execute{sql = string.format('ALTER SESSION SET CURRENT_SCHEMA = %s ;', schema), live = true}
            
         elseif this.isSqlServerConnection(connection) then
            connection:execute{sql = string.format('use %s', schema), live = true}
         end
      end
   )
    
   if not success then
      Logger.logError(errorInfo)
   end
   
   connectionMap[#connectionMap+1] = {databaseName, connection}
   
   return connection
end

function this.isSqlServerConnection(connection) 
   return connection:info().api == db.SQL_SERVER 
end

function this.isOracleConnection(connection) 
   return connection:info().api == db.ORACLE_ODBC
end
