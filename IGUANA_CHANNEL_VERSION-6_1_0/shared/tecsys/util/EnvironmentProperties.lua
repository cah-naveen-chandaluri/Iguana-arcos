-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.EnvironmentUtil'
require 'tecsys.util.TecsysIguanaProperties'
require 'tecsys.util.Util'

EnvironmentProperties = {}
local this = {}


function EnvironmentProperties.getIguanaEnvironmentType()
   --Returns P or T
   return TecsysIguanaProperties.getPropertyValue('iguana.environment.type')
end

function EnvironmentProperties.getLlpHostName(name)
   return TecsysIguanaProperties.getPropertyValue("sms.llp.%s.hostname", name)
end

function EnvironmentProperties.getLlpPort(name)
   return TecsysIguanaProperties.getPropertyValue(string.format("sms.llp.%s.port", name))
end

function EnvironmentProperties.getEnvironmentName(databaseName)
   if isNilOrEmpty(databaseName) then
      databaseName = 'default'
   end
   
   return TecsysIguanaProperties.getPropertyValue('tecsys.environment.%s.name', databaseName)
end

function EnvironmentProperties.getProtocol(databaseName)
   return TecsysIguanaProperties.getPropertyValue('tecsys.environment.%s.protocol', databaseName)
end

function EnvironmentProperties.getHostName(databaseName)
   return TecsysIguanaProperties.getPropertyValue('tecsys.environment.%s.hostname', databaseName)
end

function EnvironmentProperties.getPort(databaseName)
   return TecsysIguanaProperties.getPropertyValue('tecsys.environment.%s.port', databaseName)
end

function EnvironmentProperties.getUsername(databaseName)
   return TecsysIguanaProperties.getPropertyValue("tecsys.environment.%s.username", databaseName)
end

function EnvironmentProperties.getPassword(databaseName)

   local p = TecsysIguanaProperties.getPropertyValue("tecsys.environment.%s.password.encrypted", databaseName)
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end

   local p = TecsysIguanaProperties.getPropertyValue("tecsys.environment.%s.password", databaseName)
   if not isNilOrEmpty(p) then
      return p
   end

   return ""
end

function EnvironmentProperties.getMiUsername()
   return TecsysIguanaProperties.getPropertyValue("tecsys.mi.username", databaseName)
end

function EnvironmentProperties.getMiPassword()

   local p = TecsysIguanaProperties.getPropertyValue("tecsys.mi.password.encrypted", databaseName)
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end

   local p = TecsysIguanaProperties.getPropertyValue("tecsys.mi.password", databaseName)
   if not isNilOrEmpty(p) then
      return p
   end

   return ""
end

function EnvironmentProperties.getSoapLog()
   return TecsysIguanaProperties.getPropertyValue('log.soap')
end

function EnvironmentProperties.getInfoLog()
   return TecsysIguanaProperties.getPropertyValue('log.info')
end

function EnvironmentProperties.getSqlLog()
   return TecsysIguanaProperties.getPropertyValue('log.sql')
end

function EnvironmentProperties.getDebugLog()
   return TecsysIguanaProperties.getPropertyValue('log.debug')
end

function EnvironmentProperties.getEnvironmentInstanceName(databaseName)
   local hostname = EnvironmentProperties.getHostName(databaseName)
   local environmentName = EnvironmentProperties.getEnvironmentName(databaseName)
   return string.format("%s_%s", hostname, environmentName)

end

-------------------
-- FTP Properties
-------------------
function EnvironmentProperties.getFtpServer(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.server', siteCode)
end

function EnvironmentProperties.getFtpProtocol(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.protocol', siteCode)
end

function EnvironmentProperties.getFtpPort(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.port', siteCode)
end

function EnvironmentProperties.getFtpUsername(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.username', siteCode)
end

function EnvironmentProperties.getFtpPath(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.path', siteCode)
end

function EnvironmentProperties.getFtpSourcePath(siteCode)
   return TecsysIguanaProperties.getPropertyValue('ftp.connection.%s.source-path', siteCode)
end

function EnvironmentProperties.getFtpPassword(siteCode)

   local p = TecsysIguanaProperties.getPropertyValue("ftp.connection.%s.password.encrypted", siteCode)
   if not isNilOrEmpty(p) then
      return EnvironmentUtil.getPtp(p)
   end

   local p = TecsysIguanaProperties.getPropertyValue("ftp.connection.%s.password", siteCode)
   if not isNilOrEmpty(p) then
      return p
   end

   return ""
end

--------------------------
-- SMTP
--------------------------
function EnvironmentProperties.getSmtpHost(qualifier)
   return TecsysIguanaProperties.getPropertyValue("smtp.%s.host", qualifier)
end

function EnvironmentProperties.getSmtpPort(qualifier)
   return TecsysIguanaProperties.getPropertyValue("smtp.%s.port", qualifier)
end

function EnvironmentProperties.getSmtpUsername(qualifier)
   return TecsysIguanaProperties.getPropertyValue("smtp.%s.username", qualifier)
end

function EnvironmentProperties.getSmtpPassword(qualifier)
   local encryptedPassword = TecsysIguanaProperties.getPropertyValue("smtp.%s.password.encrypted", qualifier)
   return EnvironmentUtil.getPtp(encryptedPassword)
end