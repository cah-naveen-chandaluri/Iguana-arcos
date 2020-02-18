-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.
require 'tecsys.util.Logger'
require 'tecsys.db.DatabaseConnection'
require 'tecsys.soap.SoapAuthenticator'
local Interface = require 'tecsys.util.Interface'

local Exception = {}

function Exception.handler(success, errorInfo)
   
   local isFatal = false
   
   if not success then
      
      if DatabaseConnection.isInTransaction() then
         DatabaseConnection.rollback()
         DatabaseConnection.close()
      end   

      if type(errorInfo) ~= "number" and  errorInfo.code == '104' then
         SoapAuthenticator.login(errorInfo.database, Interface.username, Interface.password, errorInfo.qualifier)
      else  
         isFatal = true; trace('Stop retrying if the process is in a retrying mode.')
      end 
      -- Print error tree recursively
      Logger.logError(errorInfo)

      --[[
      -- Test errorInfo and determine if it is fatal and the channel should stop
         if {Fatal condition} then
            isFatal = true -- will stop the channel
         else      
            -- Based on custom logic set success to true
            if {review errorInfo} then
               success = true
            end 
         end
      ]]
   end
   
   return success, isFatal
end    

function Exception.concat(obj, str)
   if type(obj) == 'string' then
      obj = obj:trimWS()..'\n\n'..str
   else
      obj.Message = str
   end   
   return obj
end 

local exceptionHelp={
   SummaryLine = 'Retries a function, using the specified retries and pause time.',
   Desc =[[You can customize error handling by using this function.
   <p>
   Any number of functions arguments are supported, in the form: arg1, arg2,... argN.]],        
   Usage = "Exception.handler(success, errorInfo)]}",
   ParameterTable=true,
   Parameters ={ {success={Desc='Execution result of a function run by retry.call'}}, 
      {errorInfo={Desc='Contains details of error'}},
   },
   Returns ={ {Desc='<b>Multiple Returns</b>: fatalError=true causes the channel to top. Otherwise continue to retry or complete'}, 
   },
   Title = 'Exception.handler',  
}

help.set{input_function=Exception.handler,help_data=exceptionHelp}

return Exception