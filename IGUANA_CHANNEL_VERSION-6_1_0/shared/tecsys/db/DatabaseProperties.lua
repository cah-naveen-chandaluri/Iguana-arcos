-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.TecsysIguanaProperties'
require 'tecsys.util.EnvironmentUtil'
require 'tecsys.util.StringUtil'
require 'tecsys.util.Util'

local this = {}
DatabaseProperties = {}

function DatabaseProperties.getDataSourceName(qualifier)
   return TecsysIguanaProperties.getPropertyValue("tecsys.database.%s.data-source-name", qualifier)
end

function DatabaseProperties.getSchema(qualifier)
   return TecsysIguanaProperties.getPropertyValue("tecsys.database.%s.schema", qualifier)
end

function DatabaseProperties.getUsername(qualifier)
   return TecsysIguanaProperties.getPropertyValue("tecsys.database.%s.username", qualifier)
end

function DatabaseProperties.getPassword(qualifier)
   
   local p =  TecsysIguanaProperties.getPropertyValue("tecsys.database.%s.password.encrypted", qualifier)
   
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end
   return ""
end

function DatabaseProperties.isSqlServer(qualifier)
   
   if isNilOrEmpty(qualifier) then qualifier = "default" end
   
   local dataSourceVendor = this.getDataSourceVendor(qualifier)
   
   return dataSourceVendor:equals("sqlserver")
end

function DatabaseProperties.isOracle(qualifier)
   
   if isNilOrEmpty(qualifier) then qualifier = "default" end
   
   local dataSourceVendor = this.getDataSourceVendor(qualifier)
   
   return dataSourceVendor:equals("oracle")
end

function this.getDataSourceVendor(qualifier)
   return TecsysIguanaProperties.getPropertyValue("tecsys.database.%s.data-source-vendor", qualifier)
end



