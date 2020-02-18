-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local EmailUtil = {}
local this = {}

--toAddresses: table type
--qualifier: Optional. Default value = 'default'
function EmailUtil.send(subject, message, toAddresses, fromAddress, qualfier)

   assert(type(toAddresses) == 'table', "'toAddresses' should be a type of table (not string)")
   assert(subject ~= nil and message ~= nil and #toAddresses > 0 and fromAddress ~= nil
      , "Missing required argument(s) to send email!")

   local smtpHost = EnvironmentProperties.getSmtpHost(qualfier)
   local smtpPort = EnvironmentProperties.getSmtpPort(qualfier)
   local smtpUsername = EnvironmentProperties.getSmtpUsername(qualfier)
   local smtpEncryptedPassword = EnvironmentProperties.getSmtpPassword(qualfier)

   local success, result = pcall(
      function()
         return net.smtp.send{
            server = "smtp://"..smtpHost..":"..smtpPort
            , username = smtpUsername
            , password = EnvironmentUtil.getPtp(smtpEncryptedPassword)
            , from = fromAddress
            , to = toAddresses
            , header = this.getEmailHeader(subject, toAddresses, fromAddress)
            , body = message
            , use_ssl = 'no'
            , live = isLive()
         }   
      end
   )

   if not success then
      Logger.logError({Message = "Sending email failed.", Context = {smtpHost, smtpPort, smtpUsername, smtpEncryptedPassword}, result})
   end
end   

function this.getEmailHeader(subject, toAddresses, fromAddress)
   return {
      To = toAddresses[1]; 
      From = fromAddress;   
      Date = os.date();
      Subject = subject;
   }   
end

return EmailUtil