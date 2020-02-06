local util = {}

function util.logic()
    if pcall(util.verify_Directory_Status) then  -- if 1
        if pcall(dbConnection.Verify_DBConn_Elite) then    --if 2
            if pcall(dbConnection.Verify_DBConn_Arcos) then  --if 3
                elite_data = conn_Elite_qa:execute{sql=sql_sel_elite,live=true};
            
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
        valid_status=Validation.validationForOrderData(elite_data)
        if(valid_status==true) then --if 4
            log_file:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
            del_status1=conn_Arcos_stg:query{sql=sql_delete_stg_elite_po_data,live=true}
            Sel_result=conn_Arcos_stg:query{sql=sql_sel_stg_elite_po_data, live=true}
            print(Sel_result,#Sel_result)
        else
            log_file:write(TIME_STAMP..VALIDATION_FAILED,"\n")
        end    --end if 4
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
      sql_ins_stg_elite_po_data =
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
    conn_Arcos_stg:execute{sql=sql_ins_stg_elite_po_data, live=true}
    end  	   --end for 7
    Sel_res1=conn_Arcos_stg:query{sql=sql_sel_stg_elite_po_data, live=true}
    print(Sel_res1)

    util.After_Insertion()


end

function util.After_Insertion()
    print(#Insert_Result)
    print(#tab_elite_data_correct)
    if(#Sel_res1>0) then    --if 10

        conn_Arcos_stg:query{sql=sql_comp_del_stg_elite_po_data, live=true}
        Sel_res2=conn_Arcos_stg:query{sql=sql_sel_stg_elite_po_data, live=true}

        if(#Sel_res2>0 and #Sel_res2<=#Sel_res1) then   --if 11
                                    
        Insert_Result2=conn_Arcos_stg:execute{sql=sql_ins_trnsctn, live=true}
        else
            log_file:write(TIME_STAMP.."        Insertion Failed as no data is there to insert","\n")
        end          --end if 11
    else
        log_file:write(TIME_STAMP.."        Comparision failed","\n")
    end   --end if 10
end







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
    log_file_with_today_date = "log_Arcos_Channel_2 "..os.date("%Y-%m-%d")..".txt" --lOG file name with Today Date
    print(log_file_with_today_date)
    local log_file_verify=io.open(output_log_path..log_file_with_today_date,'r')
    if log_file_verify~=nil then  --if 52
        io.close(log_file_verify)
        return io.open(output_log_path..log_file_with_today_date,'a+')
    else
        return io.open(output_log_path..log_file_with_today_date,'w')
    end  --end if 52
end  --end function getLogFile






return util

