-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

EnvironmentUtil = {}
local this = {}
local key = "tecsysEliteSerie"

function EnvironmentUtil.getPtp(p)

   local decP = filter.base64.dec(p)
   local encodedString = ""

   length = decP:len()
   for i = 1, length, 2 do
      encodedString = encodedString..string.char(decP:byte(i+1))
      encodedString = encodedString..string.char(decP:byte(i))
   end

   return filter.base64.dec(encodedString)
end

function EnvironmentUtil.generatePtp(p)

   local encP = filter.base64.enc(p)
   local encodedString = ""

   length = encP:len()
   for i = 1, length, 2 do
      encodedString = encodedString..string.char(encP:byte(i+1))
      encodedString = encodedString..string.char(encP:byte(i))
   end
   
   return filter.base64.enc(encodedString)
end

function EnvironmentUtil.isEnvironmenUp(qualifier)

   local environmentName = EnvironmentProperties.getEnvironmentName(qualifier)
   local hostName = EnvironmentProperties.getHostName(qualifier)
   local protocol = EnvironmentProperties.getProtocol(qualifier)

   local pingUrl = protocol.."://"..hostName.."/"..environmentName.."/ping.html"

   local result, statusCode
   local success, errorInfo = pcall(
      function()
         result, statusCode= net.http.get{url = pingUrl, live = true}
      end
   )

   if not success then
      Logger.logError({Url = pingUrl, errorInfo})
   end   

   if statusCode == 200 then
      return true
   end 

   return false
end