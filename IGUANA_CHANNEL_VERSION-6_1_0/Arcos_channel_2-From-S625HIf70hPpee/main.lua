-- The main function is the first function called from Iguana.
function main()

    Constants = require("Constants")
    --Properties = require("Properties")
    Validation = require("Validation")
    Procedure=require("Stored_Procedures")
    dbConnection = require("DBConnection")
    dbConnection.connectdb()
    Constants.csos_order_header_size()
    -- Properties.directory_path()
    -- Properties.db_conn()
    Procedure.firstProcedure()

    tab_elite_data_correct={}
   tab_elite_data_wrong={}

    log_file = getLogFile(output_log_path)    --calling the geLogFile function
    log_file:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")


    if pcall(verify_Directory_Status) then  -- if 1
        if pcall(Verify_DBConn_Elite) then    --if 2
            if pcall(Verify_DBConn_Arcos) then  --if 3
            elite_data = conn_Elite_qa:execute{sql=sql_query,live=true};  
           -- Arcos_data= conn_Arcos_stg:query{sql = "SELECT * FROM ArcosMDB.dbo.ScheduleItems;",live=true};
            print(elite_data,elite_data[1].ITEM_NUM,elite_data[1].QTY_RECEIVED,elite_data[1].CONFIRM_DATE,elite_data[1].VENDOR_NUM,elite_data[1].FORM_222_NUM)
            print(elite_data[1].ORG_CODE,elite_data[1].PO_NUM,elite_data[1].LINE_SEQ,elite_data[1].LICENSE_TYPE,elite_data[1].WHSE_CODE,elite_data[1].DEA_LICENSE)
          -- validationForOrderData(elite_data)   
            if(#elite_data>0) then
            valid_status=validationForOrderData(elite_data)
             if(valid_status==true) then --if 4
                 log_file:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
               del_status1=conn_Arcos_stg:query{sql="delete from ArcosMDB.dbo.stg_elite_po_data",live=true}
            
            else
                 log_file:write(TIME_STAMP..VALIDATION_FAILED,"\n")
            end    --end if 4
            valid_status=validationForOrderData(elite_data)
             if(valid_status==false) then --if 4
                 log_file:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
           del_status2=conn_Arcos_stg:query{sql="delete from ArcosMDB.dbo.stg_elite_po_data",live=true}
            else
                 log_file:write(TIME_STAMP..VALIDATION_FAILED,"\n")
            end    --end if 4
            
            print(tab_elite_data_wrong,del_status2)
            print(tab_elite_data_wrong[1].ITEM_NUM,tab_elite_data_wrong[1].QTY_RECEIVED,tab_elite_data_wrong[1].CONFIRM_DATE)
            print(tab_elite_data_wrong[1].VENDOR_NUM,tab_elite_data_wrong[1].FORM_222_NUM,tab_elite_data_wrong[1].ORG_CODE)
            print(tab_elite_data_wrong[1].PO_NUM,tab_elite_data_wrong[1].LINE_SEQ,tab_elite_data_wrong[1].LICENSE_TYPE)
            print(tab_elite_data_wrong[1].WHSE_CODE,tab_elite_data_wrong[1].DEA_LICENSE)
            if(del_status2 == nil) then
               --SqlInsert=("INSERT INTO ArcosMDB.dbo.stg_elite_po_data(item_num,qty_received,confirm_date,vendor_num,form_222_num,org_code,po_num,line_seq,license_type,whse_code,dea_licens) VALUES ('"..trim(tostring(tab_elite_data_wrong[1].ITEM_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].QTY_RECEIVED)).."','"..trim(tostring(tab_elite_data_wrong[1].CONFIRM_DATE))).."','"..trim(tostring(tab_elite_data_wrong[1].VENDOR_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].FORM_222_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].ORG_CODE)).."','"..trim(tostring(tab_elite_data_wrong[1].PO_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].LINE_SEQ)).."','"..trim(tostring(tab_elite_data_wrong[1].LICENSE_TYPE)).."','"..trim(tostring(tab_elite_data_wrong[1].WHSE_CODE)).."','"..trim(tostring(tab_elite_data_wrong[1].DEA_LICENSE)).."')")
          		for i=1,#elite_data do
          		  SqlInsert =
   
   [[
   INSERT INTO ArcosMDB.dbo.stg_elite_po_data(item_num,
               qty_received,
               confirm_date,
               vendor_num,
               form_222_num,
               org_code,
               po_num,
               line_seq,
               license_type,
               whse_code,
               dea_license
   )
   VALUES
   (
   ]]..
  
  
   "'"..tab_elite_data_wrong[i].ITEM_NUM.."',"..
   "\n   '"..tab_elite_data_wrong[i].QTY_RECEIVED.."',"..
   "\n   '"..tab_elite_data_wrong[i].CONFIRM_DATE.."',"..
               "\n   '"..tab_elite_data_wrong[i].VENDOR_NUM.."',"..
               "\n   '"..tab_elite_data_wrong[i].FORM_222_NUM.."',"..
               "\n   '"..tab_elite_data_wrong[i].ORG_CODE.."',"..
               "\n   '"..tab_elite_data_wrong[i].PO_NUM.."',"..
               "\n   '"..tab_elite_data_wrong[i].LINE_SEQ.."',"..
               "\n   '"..tab_elite_data_wrong[i].LICENSE_TYPE.."',"..
               "\n   '"..tab_elite_data_wrong[i].WHSE_CODE.."',"..
   "\n   '"..tab_elite_data_wrong[i].DEA_LICENSE.."'".. 
   
   
   
   '\n   )'
                   Insert_Result=conn_Arcos_stg:execute{sql=SqlInsert, live=true}
          		
        end  		
          	if(Insert_Result~=nil) then
                  SqlDelete=[[DELETE s
FROM stg_elite_po_data s
inner join trnsctn t on s.item_num = t.item_id
WHERE 
s.vendor_num = t.cust_id
AND 
s.po_num= t.ship_po_num
AND 
s.line_seq= t.ship_po_line_num
                  ]]
                  
                  SqlInsert2=[[Delete_Result=conn_Arcos_stg:execute{sql=SqlInsert, live=true}
                  
                  INSERT INTO trnsctn (item_id, quantity, trnsctn_date, cust_id, order_form_id, assoc_registrant_dea, trnsctn_cde, row_add_stp, row_add_user_id, cord_dea, order_num, ship_po_num, ship_po_line_num, unit, whse)
Select(item_num,qty_received,confirm_date,vendor_num,form_222_num,dea_license,'P',Getdate(),'Iquana User -' + Getdate(),CASE WHEN whse_code = "CORD100" THEN 'RC0229965' ELSE 'RC0361206' END  AS CordDEA,po_num,po_num,line_seq,'',whse_code)
from  stg_elite_po_data
                  ]]
                  
                  
                  Insert_Result_Tran=conn_Arcos_stg:execute{sql=SqlInsert2, live=true}
                  
                  
                  
                  
                  else
                           log_file:write(TIME_STAMP.."        Insertion Failed","\n")
                  end
          		
          		
          		
          		
          		
          		
          		
          		
          		
-- SqlInsert=("INSERT INTO ArcosMDB.dbo.ScheduleItems(item_num, lic_reqd, baccs, break_code, use_break_code, upc, desc_1, sched1, sched2, sched3, sched4, sched5, sched6, sched7, sched8) VALUES ('"..trim(tostring(export_schedule_items_from_elite[i].item_num)).."','"..trim(tostring(export_schedule_items_from_elite[i].lic_reqd)).."','"..trim(tostring(export_schedule_items_from_elite[i].baccs)).."','"..trim(tostring(export_schedule_items_from_elite[i].break_code)).."','"..trim(tostring(export_schedule_items_from_elite[i].use_break_code)).."','"..trim(tostring(export_schedule_items_from_elite[i].upc)).."','"..trim(tostring(export_schedule_items_from_elite[i].desc_1)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched1)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched2)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched3)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched4)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched5)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched6)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched7)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched8)).."')")
                  --SqlInsert=("select * from ArcosMDB.dbo.ScheduleItems")
                 -- conn_Arcos_stg:execute{sql=SqlInsert}
            else
                log_file:write(TIME_STAMP.."        Data not got deleted from stg_elite_po_data table","\n")
            end
            else
                log_file:write(TIME_STAMP.."No data found in elite_data,"\n")
            end
            
            else
                log_file:write(TIME_STAMP..DB_CON_ERROR_ARCOS_STG,"\n")
            end   --end if 3
        else
            log_file:write(TIME_STAMP..DB_CON_ERROR_ELITE,"\n")
        end  --end if 2
    else
        log_file:write(TIME_STAMP..LOG_DIR_MISS,"\n")
    end  --end if 1
    log_file:write(TIME_STAMP..CHANNEL_STOPPED_RUNNING,"\n\n")
end  ---end main function



          --  function fun(elite_data,Arcos_data)   --function 99
                                   
                         
   -- end --fun 99
          

function Verify_DBConn_Elite()  --function for validating db connection
    return conn_Elite_qa:check()
end  --end Verify_DBConn_Elite() function



function Verify_DBConn_Arcos()  --function for validating db connection
    return conn_Arcos_stg:check()
end  --end Verify_DBConn_Arcos() function



function verify_Directory_Status()  --function for verifying directory status

    if(result_LogDirectory_Status==false)   then   -- checking for directory exist or not   --if 99
        log_file:write(TIME_STAMP..LOG_DIR_MISS,"\n") --checking
        os.fs.mkdir(output_log_path)
        log_file:write(TIME_STAMP..LOG_DIR_CREATE,"\n") --checking
        result_LogDirectory_Status=os.fs.access(output_log_path)
end  --end if 99
end   --end verify_Directory_Status()



function getLogFile(output_log_path)  -- function getLogFile
    result_LogFileDirectory_Status=os.fs.access(output_log_path)
    if(result_LogFileDirectory_Status==false) then  --if 51 -- checking for directory exist or not
        os.fs.mkdir(output_log_path)
    end   --end if 51
    log_file_with_today_date = "log_fghfhg "..os.date("%Y-%m-%d")..".txt" --lOG file name with Today Date
    print(log_file_with_today_date)
    local log_file_verify=io.open(output_log_path..log_file_with_today_date,'r')
    if log_file_verify~=nil then  --if 52
        io.close(log_file_verify)
        return io.open(output_log_path..log_file_with_today_date,'a+')
    else
        return io.open(output_log_path..log_file_with_today_date,'w')
    end  --end if 52
end  --end function getLogFile

--[[ print(elite_data,elite_data[1].ITEM_NUM,elite_data[1].LIC_REQD,elite_data[1].DEA_SCHEDULE_LIST)
            print(elite_data[1].LICENSE_TYPE,elite_data[1].BACCS,elite_data[1].BREAK_CODE,elite_data[1].UPC)
            print(elite_data[1].USE_BREAK_CODE,elite_data[1].DESC_1,elite_data[1].SCHED1,elite_data[1].SCHED2)
            print(elite_data[1].SCHED3,elite_data[1].SCHED4,elite_data[1].SCHED5,elite_data[1].SCHED6,elite_data[1].SCHED7)
            print(elite_data[1].SCHED8,elite_data[1].CONTR_SUBST)     
            
              print(Arcos_data[1].item_num,Arcos_data[1].lic_reqd,Arcos_data[1].sched1,Arcos_data[1].sched2,Arcos_data[1].sched3)
            print(Arcos_data[1].sched4,Arcos_data[1].sched5,Arcos_data[1].sched6,Arcos_data[1].sched7,Arcos_data[1].sched8)
            print(Arcos_data[1].contr_subst,Arcos_data[1].baccs,Arcos_data[1].break_code,Arcos_data[1].use_break_code)
            print(Arcos_data[1].desc_1,Arcos_data[1].ScheduleItem_ID,Arcos_data[1].upc,Arcos_data[1].DEA_Schedule_List)
            print(Arcos_data[1].License_type)




 print(elite_data,elite_data[1].ITEM_NUM,elite_data[1].QTY_RECEIVED,elite_data[1].CONFIRM_DATE,elite_data[1].VENDOR_NUM,elite_data[1].FORM_222_NUM)
 print(elite_data[1].ORG_CODE,elite_data[1].PO_NUM,elite_data[1].LINE_SEQ,elite_data[1].LICENSE_TYPE,elite_data[1].WHSE_CODE,elite_data[1].DEA_LICENSE)
           
]]--





-- Validating the order data
function validationForOrderData(elite_data)
   
local validateion_status = false
   for i=1,#elite_data do
      ELITE_LICENSE_TYPE=tostring(elite_data[i].LICENSE_TYPE)
      print(type(ELITE_LICENSE_TYPE),type(elite_data[1].CONFIRM_DATE),type(elite_data[1].QTY_RECEIVED),type(elite_data[i].PO_NUM))
      print(#elite_data[1].CONFIRM_DATE)
   
 if(  --if 21
      Validation.validate_value_string(elite_data[i].ITEM_NUM,ITEM_NUM)   --if 11
      and Validation.validate_value_num(elite_data[i].QTY_RECEIVED,QTY_RECEIVED)  --need to check
      --and Validation.validate_value_userdata(elite_data[i].CONFIRM_DATE,CONFIRM_DATE)  --need to check
      and Validation.validate_value_string(elite_data[i].VENDOR_NUM,VENDOR_NUM) 
      and Validation.validate_value_string(elite_data[i].FORM_222_NUM,FORM_222_NUM) 
       and Validation.validate_value_string(elite_data[i].ORG_CODE,ORG_CODES)
       and Validation.validate_value_num(elite_data[i].PO_NUM,PO_NUM)  --need to check  -- size is 38
        and Validation.validate_value_num(elite_data[i].LINE_SEQ,LINE_SEQ)  --need to check -- size is 38
         and Validation.validate_value_string(elite_data[i].LICENSE_TYPE,LICENSE_TYPE)
         and Validation.validate_value_string(elite_data[i].WHSE_CODE,WHSE_CODE)
            and Validation.validate_value_string(elite_data[i].DEA_LICENSE,DEA_LICENSE)
    )then     
            validateion_status = true
            tab_elite_data_correct[i]=elite_data[i]
      else
            validateion_status = false
         print(elite_data[i])
            tab_elite_data_wrong[i]=elite_data[i]
      end --end if 21
      
      end  --end for
   print(tab_elite_data_correct,tab_elite_data_wrong)
   return validateion_status
end  --end validationForOrderData() function
   