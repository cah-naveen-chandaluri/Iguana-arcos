-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.EnvironmentProperties'
require 'tecsys.util.StringUtil'

SoapProperties = {}
local this = {}

function SoapProperties.getEndpointUrl(databaseName, qualifier)
   
   local urlPattern = "%s://%s/%s/ws/%s"
   
   local environmentName = EnvironmentProperties.getEnvironmentName(qualifier)
   local hostName = EnvironmentProperties.getHostName(qualifier)
   local protocol = EnvironmentProperties.getProtocol(qualifier)
   local port = EnvironmentProperties.getPort(qualifier)
  
   local webServiceName = string.format("%s%sWebService", databaseName:sub(1, 1):upper(), databaseName:sub(2, databaseName:len()))

    if isNilOrEmpty(port) then
      return string.format("%s://%s/%s/ws/%s", protocol, hostName, environmentName, webServiceName)
   else
      return string.format("%s://%s:%s/%s/ws/%s", protocol, hostName, port, environmentName, webServiceName)
   end  
end

function SoapProperties.getMsgEndpointUrl(webServiceName, qualifier)
   
   local environmentName = EnvironmentProperties.getEnvironmentName(qualifier)
   local hostName = EnvironmentProperties.getHostName(qualifier)
   local protocol = EnvironmentProperties.getProtocol(qualifier)
   local port = EnvironmentProperties.getPort(qualifier)
   
   if isNilOrEmpty(webServiceName) then
      webServiceName = "MetaWebService"
   end   
   
   if port:isEmpty() then
      return string.format("%s://%s/%s/ws/%s", protocol, hostName, environmentName, webServiceName)
   else
      return string.format("%s://%s:%s/%s/ws/%s", protocol, hostName, port, environmentName, webServiceName)
   end
end

function SoapProperties.getUsername(databaseName)
   return EnvironmentProperties.getUsername(databaseName)
end

function SoapProperties.getPassword(databaseName)
   return EnvironmentProperties.getPassword(databaseName)
end