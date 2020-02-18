-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

Interface = Interface or require "tecsys.util.Interface"
local Notification = require "cardinal.util.Notification"
local CUtil =  require "cardinal.util.Util"

local InterfaceFile = {}
local this = {}

local InterfaceFileView = 'meta_interface_file_ce.webservice'

function InterfaceFile.create(args)

   local row = CUtil.getTemplateNode(InterfaceFileView, INTERFACE_DB, INTERFACE_QUALIFIER)

   --Mapping
   trace(row)
   map(row.OrganizationCode, args.organization)
   map(row.FileName, args.filename)
   map(row.FileType, args.fileType)
   map(row.FileSource, args.fileSource)
   map(row.Status, args.status)
   map(row.Reference, args.reference)
   map(row.ErrorMessage, args.errorMessage)
   map(row.FileContent, args.fileContent)
   map(row.DocumentType, args.docType)
   map(row.FilePath, args.attachmentPath)
   map(row.ProjectType, args.projectType)

   if args.fileType == FileType.XML then
      local dataNode = xml.parse{data=args.fileContent}
      map(row.IsaCtrlID, dataNode.Transactions.ISA:nodeText())
      map(row.PartnerID, dataNode.Transactions.PartnerId:nodeText())

   elseif this.requiresIsaPartnerIds(args) then
      map(row.IsaCtrlID, args.isaCtrlId)
      map(row.PartnerID, args.partnerId)
   end   

   local rowXmlNode = row:removeEmptyChildNode({'ErrorMessage'})
   local response =  CUtil.sendSoapUpdateRequest(rowXmlNode:S(), 'meta', INTERFACE_QUALIFIER, SoapRequest.Action.Create) 
   
   return InterfaceFile.getRecordId(response)
end

function this.requiresIsaPartnerIds(args)
   return args.fileType == FileType.X12 or args.docType == DocType.CAR or args.docType == DocType.SAR
end

function InterfaceFile.updateStatus(recordId, toStatus, errMsg)

   local row = CUtil.getTemplateNode(InterfaceFileView, INTERFACE_DB, INTERFACE_QUALIFIER)

   map(row.RecordId, recordId)
   map(row.Status, toStatus)
   map(row.Reference, reference)
   map(row.ErrorMessage, str(errMsg))

   local rowXmlNode = row:removeEmptyChildNode({'ErrorMessage'})
   return this.processUpdate(rowXmlNode, recordId, SoapRequest.Action.Update)
end

function InterfaceFile.update(args)
   
   local row = CUtil.getTemplateNode(InterfaceFileView, INTERFACE_DB, INTERFACE_QUALIFIER)

   map(row.RecordId, args.recordId)
   map(row.Status, args.status)
   map(row.ErrorMessage, args.errMsg)
   map(row.EdiOrderRecordId, args.ediOrderId)

   local rowXmlNode = row:removeEmptyChildNode({'ErrorMessage'})
   return this.processUpdate(rowXmlNode, args.recordId, SoapRequest.Action.Update)
end

function this.processUpdate(rowXmlNode, recordId, action)

   local xmlResponse, responseStatus
   local success, errorInfo = pcall(
      function()
         xmlResponse, responseStatus = CUtil.sendSoapUpdateRequest(rowXmlNode:S(), 'meta', INTERFACE_QUALIFIER, action)
      end
   )

   --Send notification email for checked error. 
   if not success or not SoapResponse.isTransactionSuccessful(xmlResponse) then
      return false, responseStatus, errorInfo
   end
   
   return true, responseStatus, ''
end

--NOTE: This function delete any attachment as well as interface file record
function InterfaceFile.delete(recordIds)

   assert(type(recordIds) == 'table', "Make sure that recordIds is 'table' type")

   if #recordIds == 0 then return end

   local interfaceFileRow, attachmentRow
   local dataTrans = ""

   for i = 1, #recordIds do
      if not isNilOrEmpty(recordIds[i]) then
         interfaceFileRow = CUtil.getTemplateNode(InterfaceFileView, INTERFACE_DB, INTERFACE_QUALIFIER)
         map(interfaceFileRow.RecordId, recordIds[i])
         interfaceFileRow:removeEmptyChildNode()

         dataTrans = dataTrans..interfaceFileRow:S().."\n"
      end   
   end

   trace(dataTrans)
   local response = CUtil.sendSoapUpdateRequest(dataTrans, 'meta', INTERFACE_QUALIFIER, SoapRequest.Action.Delete) 
end

function InterfaceFile.getRecordIdsForReference(ref)
   
   local result = InterfaceFile.search{reference=ref}
   local recordIds = {}
   for i = 1, #result do
      recordIds[#recordIds+1] = result:child(INTERFACE_VIEW_ALTID, i).RecordId:nodeText()
   end
   
   return recordIds
end

function InterfaceFile.search(args)

   local viewname = iif (isNilOrEmpty(args.viewname), InterfaceFileView, args.viewname)
   local username = EnvironmentProperties.getUsername(INTERFACE_QUALIFIER)
   local password = EnvironmentProperties.getPassword(INTERFACE_QUALIFIER)
   local criteriaViewNode = SoapRequest.getCriteriaViewNode(
      viewname
      , EnvironmentProperties.getUsername(INTERFACE_QUALIFIER)
      , INTERFACE_QUALIFIER
   )
   local criteria = criteriaViewNode[1]

   --Set custom criteria here
   map(criteria.DocumentType, args.docType)
   map(criteria.Status, args.status) 
   map(criteria.FileSource, args.fileSource) 
   map(criteria.FileType, args.fileType) 
   map(criteria.FileName, args.filename) 
   map(criteria.OrganizationCode, args.organization) 
   map(criteria.IsaCtrlID, args.isaCtrlId) 
   map(criteria.PartnerID, args.partnerId) 
   map(criteria.Reference, args.reference) 
   
   criteria:removeEmptyChildNode()
   
   local response = SoapRequest.search('meta', criteriaViewNode, true, username, password, INTERFACE_QUALIFIER)
   return SoapResponse.getSearchResultNode(response)
end

function InterfaceFile.getRecordId(response)
   if isLive() then
      return SoapResponse.getTransactionsNode(response).data[INTERFACE_VIEW_ALTID].RecordId:nodeText()
   end 

   return 0
end

--HELP
local InterfaceFileCreateHelp={
   SummaryLine = 'Create a record in interface_file_ce table',
   Desc =[[Send SOAP request with 'create' action to populate a new record in interface_file_ce table]],        
   Usage = [[InterfaceFile.create{
   organization='U1'
   , filename='20190820123533_U1____852.xml'
   , fileType=FileType.XML
   , fileContext='Hello world'
   , fileSource=Source.OpenText
   , status=Status.New
   , docType=DocType[852]
}]],
   ParameterTable=true,
   Parameters ={
      [1]={['organization']={['Desc']='Organization'}},
      [2]={['filename']={['Desc']='Filename'}},
      [3]={['fileType']={['Desc']='File type. e.g. FileType.XML, FileType.X12, ...'}},
      [4]={['fileContent']={['Desc']='File Content. Applicable only to text files.'}},
      [5]={['fileSource']={['Desc']='Source system generated the file. e.g. Source.OpenText, Source.SFTP,...'}},
      [6]={['status']={['Desc']='Default status: New. e.g. Status.New, Status.Processed,...'}},
      [7]={['docType']={['Desc']='Document Type. e.g. DocType.850, DocType.940, ...'}},
      [8]={['attachmentPath']={['Desc']='Optional. Attachment file path'}},
      [9]={['isaCtrlId']={['Desc']='Optional. ISA Control Id. Applicable only to x12 files'}},
      [10]={['partnerId']={['Desc']='Optional. Partner(Sender/Receiver) ID. Applicable only to x12 files'}},
      [11]={['reference']={['Desc']='Optional. Cross reference among records with the same source file'}},
      [12]={['projectType']={['Desc']='Type of project associated to the transaction. e.g. PROJECT.SMS, PROJECT.OPTXT'}}
   },
   Returns ={{Desc=''}},
   Title = 'InterfaceFile.create'
}

local InterfaceFileSearchHelp={
   SummaryLine = 'Search records in interface_file_ce table',
   Desc =[[Send SOAP request with 'search' action to find records with criteria in interface_file_ce table]],        
   Usage = [[InterfaceFile.search{
   organization='U1'
   , fileType=FileType.XML
   , fileSource=Source.OpenText
   , status=Status.New..";"..Status.Error
   , docType=DocType[852]
}]],
   ParameterTable=true,
   Parameters ={
      [1]={['organization']={['Desc']='Organization'}},
      [2]={['filename']={['Desc']='Filename'}},
      [3]={['fileType']={['Desc']='File type. e.g. FileType.XML, FileType.X12, ...'}},
      [4]={['fileContent']={['Desc']='File Content. Applicable only to text files.'}},
      [5]={['fileSource']={['Desc']='Source system generated the file. e.g. Source.OpenText, Source.SFTP,...'}},
      [6]={['status']={['Desc']='Default status: New. e.g. Status.New, Status.Processed,...'}},
      [7]={['docType']={['Desc']='Document Type. e.g. DocType.850, DocType.940, ...'}},
      [8]={['attachmentPath']={['Desc']='Attachment file path'}},
      [9]={['isaCtrlId']={['Desc']='ISA Control Id. Applicable only to x12 files'}},
      [10]={['partnerId']={['Desc']='Partner(Sender/Receiver) ID. Applicable only to x12 files'}},
      [11]={['reference']={['Desc']='Cross reference among records with the same source file'}}
   },
   Returns ={{Desc=''}},
   Title = 'InterfaceFile.search'
}

help.set{input_function=InterfaceFile.create, help_data=InterfaceFileCreateHelp}
help.set{input_function=InterfaceFile.search, help_data=InterfaceFileSearchHelp}

return InterfaceFile