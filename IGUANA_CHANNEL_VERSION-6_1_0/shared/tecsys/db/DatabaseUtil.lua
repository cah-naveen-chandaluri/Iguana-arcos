-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.Util'
require 'tecsys.util.StringUtil'

DatabaseUtil = {}

function DatabaseUtil.setColumnValue(table, columnName, value)
   
   if not isNilOrEmpty(value) then
      table[columnName] = value
   else
      table:remove(columnName)
   end
end

function DatabaseUtil.removeNull(table)
   trace(#table)
   for i=#table, 1, -1 do     
      if table[i]:S():equals("NULL") then
         table:remove(table[i]:nodeName())
      end
   end
end

function DatabaseUtil.setColumn(table, columnName, node, field)
   --e.g. DatabaseUtil.setColumn(table, table.address1:nodeName(), customer, customer.Address1)
   if isNilOrEmpty(field) then
      table:remove(columnName)
   else   
      if node:hasChild(field:nodeName()) and node[field:nodeName()]:hasValue() then
         table[columnName] = field[1]:nodeValue()
      else
         table[columnName] = ""
      end
   end
end

function DatabaseUtil.setAuditColumns(databaseName, row, instanceName)
   local username = EnvironmentProperties.getUsername(databaseName)
   local timestamp = DatabaseConnection.getCurrentTimestamp(databaseName, instanceName)

   row.create_stamp = timestamp
   row.create_user = username
   row.mod_stamp = timestamp
   row.mod_user = username
   row.mod_counter =  0
end  

function DatabaseUtil.setAuditColumnsUpdate(databaseName, row)
   local username = EnvironmentProperties.getUsername(databaseName)
   local timestamp = DatabaseConnection.getCurrentTimestamp(databaseName)

   row.mod_stamp = timestamp
   row.mod_user = username
   row.mod_counter =  0
end   

function DatabaseUtil.getTable(dbSchema)
   local table = dbSchema:tables()
   local rows = table[1]
   local row = table[1][1]  
   
   return table, row
end   