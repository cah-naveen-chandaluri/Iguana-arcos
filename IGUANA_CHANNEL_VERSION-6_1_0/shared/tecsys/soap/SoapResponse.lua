-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

local HttpUtils = require "tecsys.util.Http"

SoapResponse = {}
local this = {} 

function SoapResponse.isUpdateRequestSuccessful(responseNodeTree, httpStatusCode)
   return HttpUtils.isSuccessful(httpStatusCode) and SoapResponse.isResponseSuccessful(responseNodeTree)
end 

function SoapResponse.isSearchRequestSuccessful(responseNodeTree, httpStatusCode)
   return HttpUtils.isSuccessful(httpStatusCode) and SoapResponse.isResponseSuccessful(responseNodeTree)
end 

function SoapResponse.isTransactionSuccessful(responseNodeTree)
   
   if not isLive() then return true end
   
   local transNode = SoapResponse.getTransactionsNode(responseNodeTree)
   
   if node ~= nil and transNode.status.code[1]:S():equals('0') then
      return true
   end
   
   return false
end   

function this.isValidResponse(responseNodeTree)
   if not table.containsKey(responseNodeTree, "soap:Envelope") then
      return false
   end
   
   if table.containsKey(responseNodeTree["soap:Envelope"]["soap:Body"], "ns2:searchResponse") or
      table.containsKey(responseNodeTree["soap:Envelope"]["soap:Body"], "ns2:updateResponse") then
      return true
   end

   return false
end

function SoapResponse.getTransactionsNode(responseNodeTree)
   if not this.isValidResponse(responseNodeTree) then return nil end
   return responseNodeTree["soap:Envelope"]["soap:Body"]["ns2:updateResponse"]["return"].transactions
end

function SoapResponse.getSearchResultNode(responseNodeTree)
   if not this.isValidResponse(responseNodeTree) then return nil end
   return responseNodeTree["soap:Envelope"]["soap:Body"]["ns2:searchResponse"]["return"].result
end

function SoapResponse.isInvalidAccessToken(responseNodeTree)
   if not this.isValidResponse(responseNodeTree) then return nil end
   return responseNodeTree["soap:Envelope"]["soap:Body"][1]["return"].status.code:nodeText():equals('104')
end

function SoapResponse.isResponseSuccessful(responseNodeTree)
   if not this.isValidResponse(responseNodeTree) then return nil end
   return responseNodeTree["soap:Envelope"]["soap:Body"][1]["return"].status.code:nodeText():equals('0')
end

function SoapResponse.validateHttpReturnStatus(httpCode, endPointUrl, request, response)
   -- Throw error when HTTP request fails.
   if not HTTPCODE.isSuccess(httpCode) then
      Logger.logError({Message = 'HTTP request failed with '..httpCode, Endpoint = endPointUrl, Request=request, Response=response})
   end  
end   

return SoapResponse