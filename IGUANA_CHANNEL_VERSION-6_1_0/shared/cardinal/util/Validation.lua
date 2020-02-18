-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local Validation = {}
local this = {}

local iguanaEnvVar = {
   'InterfacePropertiesSchema',
   'InterfaceDataSourceVendor',
   'InterfaceDataSource',
   'InterfaceDatabaseUsername',
   'InterfaceDatabasePassword',
   'InterfacePropertiesTable'
}

--Validate iguana environment vars and db connection for interface properties table.
function Validation.checkIguanaEnvVars()

   for i = 1, #iguanaEnvVar do
      if isNilOrEmpty(os.getenv(iguanaEnvVar[i])) then
         Logger.logError("Iguana environment variable '"..iguanaEnvVar[i].."' is not defined or requires a value.")
      end
   end   

   --Test connection
   local success, result = pcall(
      function()
         local conn = TecsysIguanaProperties.getConnection()
         conn:query('select count(*) from '..os.getenv('InterfacePropertiesTable'))
      end
   )
   
   if not success then
      Logger.logError(result)
   end   

end

return Validation