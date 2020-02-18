-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local CProps = require "cardinal.util.CProperties"

local ApiHelper = {}
local this = {}

local DEF_REQ_TIMEOUT = 1500000

-- endpointUrl: Required.
-- method: Optional. Detault = 'get'
-- host: Optional. Detault = Extracted from the endpoint Url
-- contentType: Optional. Detault = application/json
function ApiHelper.callApi(endpointUrl, method, data, host, contentType)

   assert(endpointUrl ~= nil)

   --Get host from the endpointUrl
   if isNilOrEmpty(host) then host = endpointUrl:match"^%w+://([^:/]+)"  end
   if isNilOrEmpty(contentType) then contentType = CONTENT_TYPE["JSON-APP"] end
   if isNilOrEmpty(method) then method = "get"  end
   method = method:lower()

   local result, httpCode, header
   local success, errorInfo = pcall(
      function()
         result, httpCode, header = net.http[method]{
            url = endpointUrl, 
            headers = ApiHelper.getHeader(host, contentType), 
            timeout = DEF_REQ_TIMEOUT,
            live = isLive() or method == 'get',
            body = data
         }
      end
   )

   if success then
      Logger.logInfo({EndpointUrl = endpointUrl, Data = data, ReturnCode = httpCode})
   else 
      if isLive() then
         Logger.logError({ErrorMessage = errorInfo, Data = data, {result, httpCode, header}})
      end   
   end

   return result, httpCode, header
end

function ApiHelper.getHeader(host, contentType)

   if contentType == nil then contentType = CONTENT_TYPE.PLAIN end

   local header = {['Content-Type']=contentType..'; charset=UTF-8',
      ['x-apikey'] = CProps.getSmsApiKey(),
      SOAPAction = "",
      Connection = "Keep-Alive",
      ['User-Agent'] = "Tecsys",
      Host = host}

   return header
end 

return ApiHelper