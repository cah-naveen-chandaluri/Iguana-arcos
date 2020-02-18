-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local CProperties = {}
local this = {}

--SMS API Properties
function CProperties.getSmsApiBaseUrl()
   return this.getValue('sms.api.url.base')
end

function CProperties.getSmsApiKey()
   local p = this.getValue('sms.api.key')
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end   

   return ""   
end

function CProperties.getSmsApiPostNewOrders()
   return this.getValue('sms.api.url.post-new-orders')
end

function CProperties.getSmsApiGetReadyOrders(orgCode)
   local value = this.getValue('sms.api.url.get-ready-orders')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiProcessNewOrders(orgCode)
   local value = this.getValue('sms.api.url.process-new-orders')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiPostOutboundNotification()
   return this.getValue('sms.api.url.post-outbound-notification')
end

function CProperties.getSmsApiReadyShipment(orgCode)
   local value = this.getValue('sms.api.url.get-ready-shipment')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiRejectedOrder(orgCode)
   local value = this.getValue('sms.api.url.get-rejected-orders')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiShippedOrder(orgCode)
   local value = this.getValue('sms.api.url.get-shipped-orders')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiCompleteOrder(orgCode)
   local value = this.getValue('sms.api.url.post-complete-orders')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiCompleteShipment(orgCode)
   local value = this.getValue('sms.api.url.post-complete-shipment')
   return value:gsub("OrganizationCode", orgCode)
end

function CProperties.getSmsApiRunDailyTask()
   return this.getValue('sms.api.url.run-daily-task')
end

--SMS File path Properties
function CProperties.getSmsBoundClientDataPath(orgCode)
   local path = TecsysIguanaProperties.getPropertyValue('sms.bound.'..orgCode..'.data.path')
   if isNilOrEmpty(path) then
      path = TecsysIguanaProperties.getPropertyValue('sms.bound.default.data.path')
   end   
   
   assert(not isNilOrEmpty(path), 'Interface property sms.bound.'..orgCode..'.data.path is not defined')
   
   return this.normalizePath(path)
end

function CProperties.getSmsBoundClientErrorPath(orgCode)
   local path = TecsysIguanaProperties.getPropertyValue('sms.bound.'..orgCode..'.error.path')
   if isNilOrEmpty(path) then
      path = TecsysIguanaProperties.getPropertyValue('sms.bound.default.error.path')
   end    
   
   assert(not isNilOrEmpty(path), 'Interface property sms.bound.'..orgCode..'.error.path is not defined')
   
   return this.normalizePath(path)
end

function CProperties.getClientBoundSmsDataPath(orgCode)
   local path = TecsysIguanaProperties.getPropertyValue('client.'..orgCode..'.bound.sms.data.path')
   if isNilOrEmpty(path) then
      path = TecsysIguanaProperties.getPropertyValue('client.default.bound.sms.data.path')
   end   
   
   assert(not isNilOrEmpty(path), 'Interface property client.'..orgCode..'.bound.sms.data.path is not defined')
   
   return this.normalizePath(path)
end

-- Inbound Properties
function CProperties.getTecsysBoundOpenTextDataPath()
   local property = 'tecsys.bound.opentext.data.path'
   local path = this.getValue(property)
   
   return this.normalizePath(path)   
end

function CProperties.getTecsysBoundOpenTextErrorPath()
   local property = 'tecsys.bound.opentext.error.path'
   local path = this.getValue(property)
   
   return this.normalizePath(path)
end

-- SFTP Properties
function CProperties.getTecsysBoundSftpDataPath()
   local property = 'tecsys.bound.sftp.data.path'
   local path = this.getValue(property)
   
   return this.normalizePath(path)
end

function CProperties.getTecsysBoundSftpErrorPath()
   local property = 'tecsys.bound.sftp.error.path'
   local path = this.getValue(property)
   
   return this.normalizePath(path)
end

--Returns Properties
function CProperties.getdscsaDataDir()
   local property = 'imprs.bound.default.data.path'
   local path = this.getValue(property)
   
   return this.normalizePath(path)
end 

--SMS Notification
function CProperties.getSmsFaxcomEndpoint()
   return this.getValue('sms.faxcom.soap.endpoint')
end 

function CProperties.getSmsFaxcomHost()
   return this.getValue('sms.faxcom.host')
end 

function CProperties.getSmsFaxcomPassword()
   local p = this.getValue('sms.faxcom.soap.password.encrypted')
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end   

   return ""
end 

function CProperties.getSmsFaxcomUsername()
   return this.getValue('sms.faxcom.soap.username')
end 

function CProperties.getSmsFaxcomService()
   return this.getValue('sms.faxcom.soap.service')
end 

-- Local functions 
-----------------------------------------------------------------------------------
function this.getValue(property)
   local value = TecsysIguanaProperties.getPropertyValue(property)
   value = TecsysIguanaProperties.resolvePlaceHolder(value)

   assert(not isNilOrEmpty(value), 'Interface property \''..property..'\' is not defined')
   
   return value
end 

function this.normalizePath(path)

   if path:match("\\\\.*") then 
      return path
   end

   return os.fs.name.fromNative(path)
end   
return CProperties