-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

require 'tecsys.util.EnvironmentProperties'

Logger = {}

function Logger.logError(msg)
   local ctx = {msg, source = debug.getinfo(errorIndex+1).source, method = debug.getinfo(errorIndex+1).name, 
         line = debug.getinfo(errorIndex+1).currentline, callstack = debug.traceback()}
   
   local url = iif (isNilOrEmpty(getMessageUrl()), '', getMessageUrl()..'\n')
   error(url..str(ctx))
end

-- Use this function to throw exception but continue the current program flow
-- This is useful to skip error to the next transaction in a loop 
function Logger.logCheckedError(msg)
   iguana.logWarning('[CHECKED ERROR]: '..getMessageUrl()..str(msg))
end

function Logger.logWarning(msg)
   iguana.logWarning('[WARNING]: '..getMessageUrl()..str(msg))
end

function Logger.logInfo(msg)
   local doLog = EnvironmentProperties.getInfoLog()
   if isTrue(doLog) then
      iguana.logInfo('[INFO]: '..getMessageUrl()..str(msg))
   end
end

function Logger.logDebug(msg)
   local doLog = EnvironmentProperties.getDebugLog()
   if isTrue(doLog) then
      iguana.logInfo('[DEBUG]: '..getMessageUrl()..str(msg))
   end
end

function Logger.logSql(msg)

   local doLog = EnvironmentProperties.getSqlLog()
   if isTrue(doLog) then
      iguana.logInfo('[SQL]: '..getMessageUrl()..str(msg))
   end
end

function Logger.logSoap(msg)

   local doLog = EnvironmentProperties.getSoapLog()
   if isTrue(doLog) then
      iguana.logInfo('[SOAP]: '..getMessageUrl()..str(msg))
   end
end

function Logger.logHl7(msg)
   iguana.logInfo('[HL7]: '..str(msg))
end
