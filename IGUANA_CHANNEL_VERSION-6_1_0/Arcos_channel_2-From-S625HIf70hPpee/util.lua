local util = {}

function util.logic()
    if pcall(util.verify_Directory_Status) then  -- if 1
        if pcall(util.Verify_DBConn_Elite) then    --if 2
            if pcall(util.Verify_DBConn_Arcos) then  --if 3
                elite_data = conn_Elite_qa:execute{sql=sql_query,live=true};
                -- Arcos_data= conn_Arcos_stg:query{sql = "SELECT * FROM ArcosMDB.dbo.ScheduleItems;",live=true};
                print(elite_data[1].ITEM_NUM,elite_data[1].QTY_RECEIVED,elite_data[1].CONFIRM_DATE,elite_data[1]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"])
                print(elite_data[1]["TRIM(PROD_841_D.PO_L.ORG_CODE)"],elite_data[1]["TRIM(PROD_841_D.PO_L.PO_NUM)"],elite_data[1]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"])
                print(elite_data[1]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"],elite_data[1]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"])
                print(elite_data[1].DEA_LICENSE,elite_data[1]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"])
            print(elite_data[1]["TRIM(PROD_841_D.PO_L.ORG_CODE)"]:nodeText(),#elite_data[1].ITEM_NUM)
            print(elite_data[1]["TRIM(PROD_841_D.ITEM.UPC)"])
                -- validationForOrderData(elite_data)               
            util.logic2()            
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
end


function util.logic2()   
    if(#elite_data>0) then   -- if 10
                    valid_status=util.validationForOrderData(elite_data)
                    if(valid_status==true) then --if 4
                        log_file:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
                        del_status1=conn_Arcos_stg:query{sql="delete from ArcosMDB.dbo.stg_elite_po_data",live=true}
                        Sel_result=conn_Arcos_stg:query{sql="select * from ArcosMDB.dbo.stg_elite_po_data", live=true}
                        print(Sel_result,#Sel_result)
                        --sql_delete1 = "CALL del_Procedure("
                        --..conn:quote(tostring(elite_data,elite_data[1].ITEM_NUM))..")"
                        --del_status1 = conn:execute{sql=sql_delete1, live=true};
                    else
                        log_file:write(TIME_STAMP..VALIDATION_FAILED,"\n")
                    end    --end if 4
                    valid_status=util.validationForOrderData(elite_data)
                    --[[ if(valid_status==false) then --if 4
                                                      log_file:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
                                                      del_status2=conn_Arcos_stg:query{sql="delete from ArcosMDB.dbo.stg_elite_po_data",live=true}
                                      else
                                                      log_file:write(TIME_STAMP..VALIDATION_FAILED,"\n")
                                      end    --end if 4
                                      ]]--
                    if(#Sel_result==0) then      --if 5
                         util.Before_Insertion()
                    else
                        log_file:write(TIME_STAMP.."        Data not got deleted from stg_elite_po_data table","\n")
                    end   --end if 5
  else
      log_file:write(TIME_STAMP.."        No data found in elite_data","\n")
  end    --end if 10

end

function util.Before_Insertion()
                        for i=1,#elite_data do    --for 7
                            --conn:execute{sql=[[START TRANSACTION;]] ,live=true};
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
                    dea_license,
                    upc
                  )
                    VALUES
                  (
                  ]]..
                                "'"..tab_elite_data_correct[i].ITEM_NUM.."',"..
                                "\n   '"..tab_elite_data_correct[i].QTY_RECEIVED.."',"..
                                "\n   '"..tab_elite_data_correct[i].CONFIRM_DATE.."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L.ORG_CODE)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L.PO_NUM)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"].."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"].."',"..
                                "\n   '"..tab_elite_data_correct[i].DEA_LICENSE.."',"..
                                "\n   '"..tab_elite_data_correct[i]["TRIM(PROD_841_D.ITEM.UPC)"].."'"..
      
                                '\n   )'
                           -- Insert_Result[i]=conn_Arcos_stg:query{sql=SqlInsert, live=true}
                              conn_Arcos_stg:execute{sql=SqlInsert, live=true}
                    end  	   --end for 7 
    Sel_res1=conn_Arcos_stg:query{sql="select * from ArcosMDB.dbo.stg_elite_po_data", live=true}
      print(Sel_res1)
   
util.After_Insertion()
   
   
end

function util.After_Insertion()
                    print(#Insert_Result)
                    print(#tab_elite_data_correct)
                     if(#Sel_res1>0) then    --if 10
                                 SqlDelete2="DELETE s FROM ArcosMDB.dbo.stg_elite_po_data s inner join ArcosMDB.dbo.trnsctn t on s.item_num = t.item_id WHERE  s.vendor_num = t.cust_id AND  s.po_num= t.ship_po_num AND  s.line_seq= t.ship_po_line_num"
                --Del_Result3=conn_Arcos_stg:query{sql=SqlDelete2, live=true}
                conn_Arcos_stg:query{sql=SqlDelete2, live=true}
      Sel_res2=conn_Arcos_stg:query{sql="select * from ArcosMDB.dbo.stg_elite_po_data", live=true}
      
if(#Sel_res2>0 and #Sel_res2<=#Sel_res1) then   --if 11                            
                        SqlInsert2=[[INSERT INTO ArcosMDB.dbo.trnsctn (item_id, quantity, trnsctn_date, cust_id, order_form_id, assoc_registrant_dea, trnsctn_cde, row_add_stp, row_add_user_id, cord_dea, order_num, ship_po_num, ship_po_line_num, unit, whse, upc)
Select item_num,qty_received,confirm_date,vendor_num,form_222_num,dea_license,'P',Getdate(),'Iquana User -' + convert(varchar(100), Getdate()),CASE WHEN whse_code = 'CORD100' THEN 'RC0229965' ELSE 'RC0361206' END  AS CordDEA,po_num,po_num,line_seq,'',whse_code,upc
from  ArcosMDB.dbo.stg_elite_po_data
WHERE (form_222_num  not like  '3PL*'  OR  form_222_num  Is  Null)]]                        
                        Insert_Result2=conn_Arcos_stg:execute{sql=SqlInsert2, live=true}
else
         log_file:write(TIME_STAMP.."        Insertion Failed as no data is there to insert","\n")                
 end          --end if 11               
                    else                        
                         log_file:write(TIME_STAMP.."        Comparision failed","\n")                     
                     end   --end if 10
end





function util.Verify_DBConn_Elite()  --function for validating db connection
    return conn_Elite_qa:check()
end  --end Verify_DBConn_Elite() function



function util.Verify_DBConn_Arcos()  --function for validating db connection
    return conn_Arcos_stg:check()
end  --end Verify_DBConn_Arcos() function



function util.verify_Directory_Status()  --function for verifying directory status

    if(result_LogDirectory_Status==false)   then  --if 99  -- checking for directory exist or not   
        log_file:write(TIME_STAMP..LOG_DIR_MISS,"\n") --checking
        os.fs.mkdir(output_log_path)
        log_file:write(TIME_STAMP..LOG_DIR_CREATE,"\n") --checking
        result_LogDirectory_Status=os.fs.access(output_log_path)
end  --end if 99
end   --end verify_Directory_Status()



function util.getLogFile(output_log_path)  -- function getLogFile
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


-- Validating the order data
function util.validationForOrderData(elite_data)

    local validateion_status = false
    for i=1,#elite_data do
        --ELITE_LICENSE_TYPE=tostring(elite_data[i].LICENSE_TYPE)
        --print(type(ELITE_LICENSE_TYPE),type(elite_data[1].CONFIRM_DATE),type(elite_data[1].QTY_RECEIVED),type(elite_data[i].PO_NUM))
        -- print(#elite_data[1].CONFIRM_DATE)

        if(  --if 21
            Validation.validate_value_string(elite_data[i].ITEM_NUM,ITEM_NUM)   --if 11
            and Validation.validate_value_string(elite_data[i].QTY_RECEIVED,QTY_RECEIVED)  --need to check
            and Validation.validate_value_string2(elite_data[i].CONFIRM_DATE)  --need to check
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"],VENDOR_NUM)
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"],FORM_222_NUM)
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.ORG_CODE)"],ORG_CODES)
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.PO_NUM)"],PO_NUM)  --need to check  -- size is 38
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"],LINE_SEQ)  --need to check -- size is 38
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"],LICENSE_TYPE)
            and Validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"],WHSE_CODE)
            and Validation.validate_value_string(elite_data[i].DEA_LICENSE,DEA_LICENSE)
            and Validation.validate_value_string(elite_data[1]["TRIM(PROD_841_D.ITEM.UPC)"],UPC)
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






return util





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

            --[[print(tab_elite_data_wrong,del_status2)
            print(tab_elite_data_wrong[1].ITEM_NUM,tab_elite_data_wrong[1].QTY_RECEIVED,tab_elite_data_wrong[1].CONFIRM_DATE)
            print(tab_elite_data_wrong[1].VENDOR_NUM,tab_elite_data_wrong[1].FORM_222_NUM,tab_elite_data_wrong[1].ORG_CODE)
            print(tab_elite_data_wrong[1].PO_NUM,tab_elite_data_wrong[1].LINE_SEQ,tab_elite_data_wrong[1].LICENSE_TYPE)
            print(tab_elite_data_wrong[1].WHSE_CODE,tab_elite_data_wrong[1].DEA_LICENSE)
               ]]--

--print(elite_data,elite_data[1].ITEM_NUM,elite_data[1].QTY_RECEIVED,elite_data[1].CONFIRM_DATE,elite_data[1].VENDOR_NUM,elite_data[1].FORM_222_NUM)
                        --print(elite_data[1].ORG_CODE,elite_data[1].PO_NUM,elite_data[1].LINE_SEQ,elite_data[1].LICENSE_TYPE,elite_data[1].WHSE_CODE,elite_data[1].DEA_LICENSE)
                        
                    --SqlInsert=("INSERT INTO ArcosMDB.dbo.stg_elite_po_data(item_num,qty_received,confirm_date,vendor_num,form_222_num,org_code,
                 -- po_num,line_seq,license_type,whse_code,dea_licens) VALUES ('"..trim(tostring(tab_elite_data_wrong[1].ITEM_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].QTY_RECEIVED)).."','"..trim(tostring(tab_elite_data_wrong[1].CONFIRM_DATE))).."','"..trim(tostring(tab_elite_data_wrong[1].VENDOR_NUM)).."','"
                 -- ..trim(tostring(tab_elite_data_wrong[1].FORM_222_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].ORG_CODE)).."','"
                 -- ..trim(tostring(tab_elite_data_wrong[1].PO_NUM)).."','"..trim(tostring(tab_elite_data_wrong[1].LINE_SEQ)).."','"
                 -- ..trim(tostring(tab_elite_data_wrong[1].LICENSE_TYPE)).."','"..trim(tostring(tab_elite_data_wrong[1].WHSE_CODE)).."','"
                 -- ..trim(tostring(tab_elite_data_wrong[1].DEA_LICENSE)).."')")

