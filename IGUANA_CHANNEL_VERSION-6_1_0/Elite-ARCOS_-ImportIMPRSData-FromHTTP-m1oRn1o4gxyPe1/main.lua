-- this channel will pull the schedule item information from Elite
-- if the items are present in schedule_item table in arcos and Elite item has changed, it will update schedule_item table
-- it will insert the new item information in schedule_item table


require "tecsys.db.DatabaseConnection"
require 'tecsys.util.EnvironmentProperties'
require "tecsys.db.DatabaseUtil"
require "tecsys.util.Logger"
require "cardinal.global.DomainValue"
require "cardinal.global.Const"
require "tecsys.soap.SoapRequest"
local Constant = require("tpl.arcos.util.ArcosConstant")


local HttpUtils = require "tecsys.util.Http"
local Exception = require "tecsys.util.Exception"
local CUtil = require "cardinal.util.Util"
local Cache = require "tecsys.util.Cache"
--local Notification = require "cardinal.util.Notification"
local ImpImprsOrderData = require("tpl.arcos.channels.ImportImprsData")

errorIndex = 1
Cache.init('ArcosRunImprsImportProcess')
CUtil.initChannel()

local this ={}
local DEF_REQ_LOC = '/arcos/runImprsImportProcess'


function main(Data)

   Logger.logInfo('Retrieving HTTPS call from iTopia timer.') 

   Interface.initialize()

   local success, errorInfo = pcall(
      function()
         this.actualMain(net.http.parseRequest{data=Data})
      end
   )

   if not success then
      Exception.handler(success, string:printObject(errorInfo))
   end

end

function this.actualMain(request)

   if request.location == DEF_REQ_LOC then

      HttpUtils.sendResponse('Ok', 200)

      local success, result = pcall(
         function()
            Logger.logInfo('HTTPS call from iTopia timer validated successfully.')
            this.startEliteImprsImport()

         end -- of function
      )

      if not success then
         local errMsg = string:printObject(result)
         Logger.logCheckedError(errMsg)         
         --Notification.send(Notification.getSubject(), errMsg)
      end

   else
      httpUtils.sendResponse("URL is invalid.", 404) 
   end
end  



function this.startEliteImprsImport() 
   Logger.logInfo('Starting elite Imprs import process')
   ImpImprsOrderData.importImprsDataFromElite()
   local successMsg ='ARCOS Imprs Import Process is successful'
   Logger.logInfo(successMsg)
   --Notification.send(Notification.getSubject(), successMsg)

end 








