-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local FileUtil = require "tecsys.util.FileUtil"

local FtpUtil = {}
local this ={}
local DEF_TIMEOUT = 30

function FtpUtil.getConnection(site)
   local server = EnvironmentProperties.getFtpServer(site)
   local username = EnvironmentProperties.getFtpUsername(site)
   local password = EnvironmentProperties.getFtpPassword(site)
   local protocol = EnvironmentProperties.getFtpProtocol(site):lower()

   return net[protocol].init{server=server, username=username, password=password, timeout=DEF_TIMEOUT, live = isLive()}
end

--remotePath: path with filename
--localPath: path with filename
function FtpUtil.put(site, remotePath, data, localPath, overwrite)

   if isNilOrEmpty(overwrite) then 
      overwrite = false 
   end

   if isLive() then
      this.validateConnection(site, remotePath)
      
      if not isNilOrEmpty(localPath) then
         FtpUtil.getConnection(site):put{remote_path=remotePath, local_path=localPath, overwrite=overwrite}
      else
         assert(not isNilOrEmpty(data))
         Logger.logDebug("Writing data to a remote file "..remotePath.." at site "..site)
         FtpUtil.getConnection(site):put{remote_path=remotePath, data=data, overwrite=overwrite}
      end
   end
end 

function FtpUtil.delete(site, remotePath)

   if isLive() then 
      this.validateConnection(site, remotePath)
      Logger.logDebug("Removing a remote file "..remotePath.." at site "..site)
      FtpUtil.getConnection(site):delete{remote_path=remotePath}
   end 
end

function this.validateConnection(site, remotePath)

   local success, errorInfo = pcall (
      function ()
         FtpUtil.getConnection(site):list{remote_path=FileUtil.getDirectoryPath(remotePath)}
      end
   )

   if not success then
      Logger.logError({'Failed to connect FTP connection site '..site, errorInfo})
   end

end

return FtpUtil