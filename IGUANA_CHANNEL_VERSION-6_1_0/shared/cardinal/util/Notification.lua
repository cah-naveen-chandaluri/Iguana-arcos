-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local EmailUtil = require "tecsys.util.EmailUtil"

local checkedEmails = TecsysIguanaProperties.getPropertyValue("notification.checked.default.email")
local uncheckedEmails = TecsysIguanaProperties.getPropertyValue("notification.unchecked.default.email")
local FROM_ADDRESS = 'iguana@cardinalhealth.com'

local Notification = {}
local this = {}

--Assumption: If no recepient email is given, no email is sent.
--subject: required
--message: required
--toAddress: Optional. Default to setup in Interface Properties notification.checked.default.email
--fromAddress: Optional. Default to 'iguana@cardinalhealth.com'
--exceptionType: Optional. Default to EXCEPTION.Checked
function Notification.send(subject, message, toAddress, fromAddress, exceptionType)
   
   assert(subject ~= nil and message ~= nil)
   
   --Set default values for missing arguemnts
   exceptionType = iif (isNilOrEmpty(exceptionType), EXCEPTION.Checked, exceptionType)
   fromAddress = iif (isNilOrEmpty(fromAddress), FROM_ADDRESS, fromAddress)
   toAddresses = this.getReceipients(exceptionType)

   if #toAddresses == 1 and isNilOrEmpty(toAddresses[1]) then 
      return "Notification not sent due to no recepient email address!" 
   end
   
   EmailUtil.send(subject, message, toAddresses, fromAddress)
end

function Notification.getSubject(contextMsg)
   if contextMsg == nil then 
      contextMsg = "" 
   else
      contextMsg = "/"..contextMsg 
   end
   return "[CHECKED ERROR | "..iguana.webInfo().name.."@"..iguana.webInfo().host.."] "..iguana.channelName()..contextMsg
end

function this.getReceipients(exceptionType)

   local receipients = {}
   local emailArray = this.getEmailAddressByType(exceptionType):split(';')
   if #emailArray == 0 then
      Logger.logError("Notification email address is not setup in Interface Properties.")
   end

   for i = 1, #emailArray do 
      receipients[#receipients + 1] = emailArray[i]:trimWS()
   end  
   
   return receipients
end

function this.getEmailAddressByType(exceptionType)
   local emailAddress = checkedEmails

   if not isNilOrEmpty(exceptionType) and exceptionType == EXCEPTION.Unchecked then
      emailAddress = uncheckedEmails
   end 

   return emailAddress
end  

return Notification