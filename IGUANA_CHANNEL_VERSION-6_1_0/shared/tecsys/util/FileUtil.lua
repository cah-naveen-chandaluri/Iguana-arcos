-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'file'
require 'tecsys.util.Util'
require 'stream'
local WinExitCodes = require "tecsys.util.WinExitCodes"
local UnixExitCodes = require "tecsys.util.UnixExitCodes"

local FileUtil = {}
local this = {}

--path: path contains filename
--includePath : include path in the output
function FileUtil.getFileList(path, filename, minFileAge, includePath)

   assert(not isNilOrEmpty(path), "ERROR: Target path is empty!")

   local isUncPath = false

   if path:startWith("//") or path:startWith("\\\\") then isUncPath = true end
   if isNilOrEmpty(minFileAge) then minFileAge = 0 end
   if isNilOrEmpty(includePath) then includePath = true end

   local fileList = {}
   local success, errorInfo = pcall(

      function()
         for fileName in os.fs.glob(string.format("%s/%s", path, filename)) do

            trace(fileName)
            if FileUtil.isFile(fileName) and FileUtil.validDelaySinceLastModification(fileName, minFileAge) then

               if includePath then
                  fileList[#fileList+1] = iif (isUncPath, fileName:gsub('/','\\'), fileName)
               else
                  fileList[#fileList+1] = FileUtil.getFilename(fileName)
               end
            end

         end
         trace(fileList)
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end

   return fileList
end

function FileUtil.validDelaySinceLastModification(filePath, delay)

   local isValid = true
   local lastModifiedTimestamp = this.getLastModified(filePath)
   local success, errorInfo = pcall(
      function()
         local actualTimestamp = os.ts.gmtime()
         if  (actualTimestamp-lastModifiedTimestamp) < delay then
            isValid = false
         end
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end

   return isValid
end

function FileUtil.getFileContent(filePath)

   local fileContent
   local success, errorInfo = pcall(
      function()
         local fileStream = stream.fromFile(filePath)
         fileContent = stream.toString(fileStream)
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end

   return fileContent
end


function FileUtil.moveFile(oldDirectory, newDirectory, filePath)

   local success, errorInfo = pcall(
      function()
         local path, fileName = FileUtil.getFilenameAndPath(filePath)
         local oldFilePath = string.format("%s/%q", oldDirectory, fileName)
         local newFilePath = string.format("%s/%q", newDirectory, fileName)   

         if not os.fs.dirExists(newDirectory) then
            os.fs.mkdir(newDirectory)
         end

         local commandName 
         if os.isWindows() then
            commandName = "move"
         else
            commandName = "mv"
         end

         local command = {dir= os.fs.name.toNative(oldDirectory)
            , command=string.format(commandName.." %q %s",fileName,os.fs.name.toNative(newFilePath))
            , arguments=""}

         if isLive() then
            local exitVal = os.execute(command)
            FileUtil.validateExitCode(exitVal, command)
         else
            trace(command)
         end   
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end   
end

function FileUtil.validateExitCode(exitVal, command)
   
   Logger.logInfo("Exit code: "..exitVal..", Command: "..command)
   
   if exitVal > 0  then 
      
      if os.isWindows() then
         if UnixExitCodes[exitVal] == nil then
            Logger.logError("Unknow error occured :"..'\n'..command) 
         else
            Logger.logError(WinExitCodes[exitVal]..'\n'..command) 
         end
         
      else
         if UnixExitCodes[exitVal] == nil then
            Logger.logError("Unknow error occured :"..'\n'..command) 
         else
            Logger.logError(UnixExitCodes[exitVal]..'\n'..command) 
         end
      end
      
   end
end

function FileUtil.move(srcFilePath, destFilePath)
   if isLive() then
      os.rename(srcFilePath, destFilePath)
   end   
end

function FileUtil.moveFile2(filePath, destFolderPath)
   local content = FileUtil.getFileContent(filePath)
   local filename = FileUtil.getFilename(filePath)

   if isLive() then
      FileUtil.writeFile(destFolderPath..'/'..filename, content)
      os.remove(filePath)
   end   
end

function FileUtil.copyFile(oldDirectory, newDirectory, filePath)

   local success, errorInfo = pcall(
      function()
         local path, fileName = FileUtil.getFilenameAndPath(filePath)
         local oldFilePath = string.format("%s/%q", oldDirectory, fileName)
         local newFilePath = string.format("%s/%q", newDirectory, fileName)   

         if not os.fs.dirExists(newDirectory) then
            os.fs.mkdir(newDirectory)
         end

         local commandName 
         if os.isWindows() then
            commandName = "copy"
         else
            commandName = "cp"
         end

         local command = {dir= os.fs.name.toNative(oldDirectory)
            , command=string.format(commandName.." %q %s",fileName,os.fs.name.toNative(newFilePath))
            , arguments=""}

         local exitVal = os.execute(command)
         FileUtil.validateExitCode(exitVal, command)

      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end   
end

function this.getLastModified(filePath)

   local modificationTime
   local success, errorInfo = pcall(
      function()
         modificationTime = os.fs.stat(filePath).mtime
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end

   return modificationTime
end

--Code based on module File from iNTERFACEWARE
function FileUtil.writeFile(filepath, content, permissions)

   if isLive() then   
      local file
      local success, errorInfo = pcall(
         function()
            os.fs.name.toNative(filepath)

            local parts = filepath:split('/')
            local dir = ''
            for i = 1, #parts-1 do

               if not isNilOrEmpty(dir) then
                  dir = string.format("%s/%s", dir, parts[i])
               else
                  dir = parts[i]
               end

               if not os.fs.dirExists(dir) then
                  os.fs.mkdir(dir, 777)
               end
            end

            os.fs.access(filepath, 'w')
            local file, err = io.open(filepath, "wb+")
            if not file then
               Logger.logError({message = err})
            end

            file:write(content)
            if permissions then
               os.fs.chmod(filepath, permissions)
            end

            file:close()
         end
      )     
      if not success then
         if file ~= nil then
            file:close()
         end
         
         Logger.logError({message = errorInfo})
      end      
   end
end

function FileUtil.removeDirctory(path)

   local nativePath =  os.fs.name.toNative(path)
   
   --os.fs.name.toNative does not add '\' in front of UNC path 
   if not FileUtil.dirExists(nativePath) and not FileUtil.dirExists("\\"..nativePath) 
      then return 
   end

   local success, errorInfo = pcall(
      function()
         local command 
         if os.isWindows() then
            command = 'rmdir /s /q '..nativePath
         else
            command = 'rm -r '..nativePath
         end

         if isLive() then
            local exitVal = os.execute(command)
            FileUtil.validateExitCode(exitVal, command)
         else
            trace(command)
         end   
      end
   )

   if not success then
      Logger.logError({message = errorInfo})
   end   
end

function FileUtil.getExtension(path)
   -- e.g. Returns 'txt' from 'C:/temp/abc.txt'
   return path:match".*%.(.*)"
end

function FileUtil.getDirectoryPath(path)
   return path:match"(.*[/\\]).*"
end

function FileUtil.getFilename(path)
   return path:match".*[/\\](.*)"
end

function FileUtil.getFilenameNoExtension(filenameWithExt)
   return filenameWithExt:match".*[/\\](.*)%..*"
end

function FileUtil.getFilenameAndPath(path)
   return path:match"(.*)[/\\](.*)"
end   

function FileUtil.fileExists(path)
   return os.fs.access(path)
end   

function FileUtil.dirExists(path)
   return os.fs.dirExists(path)
end   

function FileUtil.isDirectory(path)
   return os.fs.stat(path).isdir
end

function FileUtil.isFile(path) --not directory
   return os.fs.stat(path).isreg
end

function FileUtil.getErrorDesc(exitCode)
   return exitCodes[exitCode]
end
return FileUtil