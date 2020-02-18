-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

local httpUtils={}

function httpUtils.isSuccessful(statusCode)
   
   if tonumber(statusCode) == 200 then
      return true
   end
   
   return false
end

function httpUtils.sendResponse(response, statusCode, entityType)
   
   if isNilOrEmpty(entityType) then entityType = 'text/plain' end
      
   if isNilOrEmpty(response) and not isLive() then
      response = 'Testing...'
      statusCode = 200
   end   
   
   pcall( function() 
         net.http.respond{entity_type=entityType, body=response, code=statusCode}
      end)
end


return httpUtils