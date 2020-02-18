-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local FileUtil = require "tecsys.util.FileUtil"
local CUtil = require "cardinal.util.Util"
local CProps = require "cardinal.util.CProperties"
local InterfaceFile = require "cardinal.meta.InterfaceFileCe"
local Notification = require "cardinal.util.Notification"
local ApiHelper = require "cardinal.sms.ApiHelper"
local Query = require "cardinal.sms.sql.EliteStageLoadFromStaging"

local ImportEliteTrans = {}
local this = {}

--Staging tables
local EliteStageOrderDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_Order.dbs'}
local EliteStageOrderContainerDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_OrderContainer.dbs'}
local EliteStageOrderLineDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_OrderLine.dbs'}
local EliteStageOrderStatusDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_OrderStatus.dbs'}
local EliteStageCustomerDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_Customer.dbs'}
local EliteStageSampleLotDbs = dbs.init{filename='cardinal/dbs/sms/Elite_Stage_SampleLot.dbs'}

local TRANSFER = {ERR=0, RDY=1}

function ImportEliteTrans.process()

   local trans = InterfaceFile.search{
      status=Status.New
      , docType=DocType.STG
      , fileSource=Source.DMS
      , fileType=FileType.JSON
   }

   for i = 1, trans:childCount(INTERFACE_VIEW_ALTID) do

      local currTrans = trans:child(INTERFACE_VIEW_ALTID, i)
      local recordId = currTrans.RecordId:nodeText();
      local orgCode = currTrans.OrganizationCode:nodeText();

      local success, result = pcall(
         function()
            this.createStagingRecrods(currTrans, recordId, orgCode)
            this.transferStagingToTargetTables(recordId, orgCode)
            DatabaseConnection.commit()
            
            --This line should be after db commit
            this.createOutboundNotification()
         end
      )

      if success then
         InterfaceFile.updateStatus(recordId, Status.Processed)
         Logger.logInfo("Transaction (Interface File Record ID = "..recordId..") successfully imported to SMS.")

      else
         DatabaseConnection.rollback()

         local errMsg = "Import transaction (Interface File Record ID = "..recordId..") failed to SMS."..str(result)
         Logger.logCheckedError(errMsg)
         InterfaceFile.updateStatus(recordId, Status.Error, errMsg)
         Notification.send(Notification.getSubject("Import transaction (Interface File Record ID = "..recordId..") failed to SMS."), str(result))
      end
   end  
end

--------------------------------------------------------------------------------------------
--Local functions
--------------------------------------------------------------------------------------------

function this.transferStagingToTargetTables(tag, orgCode)

   Logger.logDebug('Transferring staging data started with tag '..tag)

   --Keep the following order as in CAH stored procedure usp_elite_stage_loadFromStaging 
   this.transferStagingCustomer(tag, orgCode)
   this.transferStagingOrderStatus(tag, orgCode)
   this.transferStagingShipment(tag, orgCode)
   this.transferStagingShipmentItems(tag, orgCode)
   this.transferStagingShipmentItemLots(tag, orgCode)
   this.transferStagingShipmentContainers(tag, orgCode)
   this.transferStagingAORs(tag, orgCode) --Acknowledgement Of Receipt 

   this.deleteStaingData(tag)

   Logger.logDebug("Completed transferring staging data for organization "..orgCode.." with tag "..tag)
end

function this.createOutboundNotification()
   local endpointUrl = CProps.getSmsApiPostOutboundNotification()
   local result, httpCode, header = ApiHelper.callApi(endpointUrl, REQ_METHOD.POST)

   if not HTTPCODE.isSuccess(httpCode) then
      Logger.logError({result, httpCode, header})
   end   
end

function this.deleteStaingData(tag)
   local deleteStmt = [[delete from Elite_Stage_Customer where tag = '%s';
   delete from Elite_Stage_Order where tag = '%s';
   delete from Elite_Stage_OrderContainer where tag = '%s';
   delete from Elite_Stage_OrderLine where tag = '%s';
   delete from Elite_Stage_OrderStatus where tag = '%s';
   delete from Elite_Stage_Pdma where tag = '%s';
   delete from Elite_Stage_SampleLot where tag = '%s';]]

   deleteStmt = deleteStmt:format(tag, tag, tag, tag, tag, tag, tag)
   DatabaseConnection.executeSql(SMS_DB, deleteStmt, SMS_QUALIFIER)   
end

function this.setStaingTransferStatus(tag, isSuccess)
   local status = iif(isSuccess, TRANSFER.RDY, TRANSFER.ERR)
   local updateStmt = "update Elite_Stage_Order set transfer_status = %s where tag = '%s'"
   updateStmt = updateStmt:format(status, tag)
   DatabaseConnection.executeSql(SMS_DB, updateStmt, SMS_QUALIFIER)
   --DatabaseConnection.commit()
end

function this.createStagingRecrods(trans, tag, orgCode) --populateStagingTables
   
   Logger.logDebug('Creating staging data started for organization '..orgCode.." with tag "..tag)

   local jnode = json.parse{data=trans.FileContent:nodeText()}; trace(jnode)
   local mapper = CUtil.getMapper("sms/elite_to_sms_extract_j2d.json"); trace(mapper)

   --DB transactions
   this.createEliteStageOrder(tag, table.copy(jnode, false), table.copy(mapper, false))
   this.createEliteStageOrderLines(tag, jnode.Line, mapper.Line)
   this.createEliteStageContainers(tag, jnode.Container, mapper.Container)
   this.createEliteStageOrderStatus(tag, jnode.OrderStatus, mapper.OrderStatus)
   this.createEliteStageCustomer(tag, jnode.Customer, mapper.Customer)
   this.createEliteStageOrderLots(tag, jnode.OrderLot, mapper.OrderLot)

   Logger.logDebug('Creating staging data finished for organization '..orgCode.." with tag "..tag)
end

function this.createEliteStageOrder(tag, data, mapper)
   local schemaTable, row = DatabaseUtil.getTable(EliteStageOrderDbs)
   this.mapData(row, data, mapper)
   row.tag = tag
   row.transfer_status = TRANSFER.RDY
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end  

function this.createEliteStageOrderLines(tag, data, mapper)
   if #data == 0 then return end

   local schemaTable, row = DatabaseUtil.getTable(EliteStageOrderLineDbs)
   for i = 1, #data do
      this.mapData(schemaTable.Elite_Stage_OrderLine[i], data[i], mapper)   
      schemaTable.Elite_Stage_OrderLine[i].tag = tag
   end   
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end  

function this.createEliteStageOrderLots(tag, data, mapper)
   if #data == 0 then return end

   local schemaTable, row = DatabaseUtil.getTable(EliteStageSampleLotDbs)
   for i = 1, #data do
      this.mapData(schemaTable.Elite_Stage_SampleLot[i], data[i], mapper)   
      schemaTable.Elite_Stage_SampleLot[i].tag = tag
   end   
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end 

function this.createEliteStageContainers(tag, data, mapper)
   if #data == 0 then return end

   local schemaTable, row = DatabaseUtil.getTable(EliteStageOrderContainerDbs)

   for i = 1, #data do
      this.mapData(schemaTable.Elite_Stage_OrderContainer[i], data[i], mapper)   
      schemaTable.Elite_Stage_OrderContainer[i].tag = tag
   end   
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end 

function this.createEliteStageOrderStatus(tag, data, mapper)
   local schemaTable, row = DatabaseUtil.getTable(EliteStageOrderStatusDbs)
   this.mapData(row, data, mapper)
   row.tag = tag
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end  

function this.createEliteStageCustomer(tag, data, mapper)
   local schemaTable, row = DatabaseUtil.getTable(EliteStageCustomerDbs)
   this.mapData(row, data, mapper)
   row.tag = tag
   DatabaseConnection.merge(SMS_DB, schemaTable, true, SMS_QUALIFIER)
end  

function this.mapData(row, data, mapper)
   for col, jLabel in pairs(mapper) do
      if not isNilOrEmpty(col) then
         row[col] = data[jLabel]
      end   
   end     
end

----------------------------------------------------------------------------------------------------------------------

function this.transferStagingCustomer(tag, currOrgCode)
   local mergeStmt = Query.Customer:format(tag, tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)
end

function this.transferStagingOrderStatus(tag, currOrgCode)
   local mergeStmt = Query.OrderStatus:format(tag, tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)
end

function this.transferStagingShipment(tag, currOrgCode)
   local mergeStmt = Query.Shipment:format(tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)
end

function this.transferStagingShipmentItems(tag, currOrgCode)
   local mergeStmt = Query.ShipmentItem:format(tag, tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)
end

function this.transferStagingShipmentItemLots(tag, currOrgCode)
   local mergeStmt = Query.ShipmentItemLot:format(tag, tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)
end

function this.transferStagingShipmentContainers(tag, currOrgCode)
   local mergeStmt = Query.ShipmentContainers:format(tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)   
end

function this.transferStagingAORs(tag, currOrgCode)
   local mergeStmt = Query.AORs:format(tag)
   DatabaseConnection.executeSql(SMS_DB, mergeStmt, SMS_QUALIFIER)    
end

return ImportEliteTrans
