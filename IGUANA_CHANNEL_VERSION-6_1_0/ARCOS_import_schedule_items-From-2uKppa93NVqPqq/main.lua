-- The main function is the first function called from Iguana.
function main()

    Constants = require("Constants")
    --Properties = require("Properties")
    Validation = require("Validation")
    Procedure=require("Stored_Procedures")
    dbConnection = require("DBConnection")
   EliteSQL = require("EliteSQLs")
 ArcosSQL = require("ArcosSQL")
    dbConnection.connectdb()
    Constants.csos_order_header_size()
   ArcosSQL.queryScheduleItemsArcos()
   EliteSQL.importEliteScheduleItemData()
   
    -- Properties.directory_path()
    -- Properties.db_conn()
    Procedure.firstProcedure()

TabEliteDataCorrect={}
TabEliteDataWrong={}
   
    log_file = getLogFile(output_log_path)    --calling the geLogFile function
    log_file:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")
   
   
    if pcall(Validation.Verify_DBConn_Elite) then  -- Verifying Elite DB connection /remove this
            if pcall(Validation.Verify_DBConn_Arcos) then -- Verify Arcos DB connection/remove this
            log_file:write('starting import item info from Elite',"\n") 
            ItemDataFromElite = conn_Elite_qa:query{sql=ImportScheduleItemsFromElite,live=true};
             if pcall(Validation.validationForScheduleItemData,ItemDataFromElite) then -- validation of elite data
         
            log_file:write('Elite item count :' ..#TabEliteDataCorrect,"\n")  
            log_file:write('starting import item info from ARCOS',"\n") 
            ScheduleItemFromArcos = conn_Arcos_stg:query{sql="select * from ArcosMDB.dbo.schedule_item", live=true}
            log_file:write('ARCOS item count :' ..#ScheduleItemFromArcos,"\n")  
          
            for i=1,#TabEliteDataCorrect do
               arcos_schedule_item = true
               for j=1,#ScheduleItemFromArcos do   
                 if  ( Validation.trim(tostring(TabEliteDataCorrect[i].item_num)) == Validation.trim(Validation.trim(tostring(ScheduleItemFromArcos[j].ITEM_NUM)))) then
                     if(Validation.trim(tostring(TabEliteDataCorrect[i].lic_reqd)) == Validation.trim(tostring(ScheduleItemFromArcos[j].lic_reqd)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched1)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched1))and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched2)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched2))and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched3)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched3)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched4)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched4)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched5)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched5)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched6)) ==Validation.trim( tostring(ScheduleItemFromArcos[j].sched6)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched7)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched7)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].sched8)) == Validation.trim(tostring(ScheduleItemFromArcos[j].sched8)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].baccs ))== Validation.trim(tostring(ScheduleItemFromArcos[j].baccs)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].break_code)) == Validation.trim(tostring(ScheduleItemFromArcos[j].break_code)) and 
                     Validation.trim(tostring(TabEliteDataCorrect[i].use_break_code ))== Validation.trim(tostring(ScheduleItemFromArcos[j].use_break_code)) and
                     Validation.trim(tostring(TabEliteDataCorrect[i].upc)) == Validation.trim(tostring(ScheduleItemFromArcos[j].upc)) and 
                     Validation.trim(tostring(TabEliteDataCorrect[i].desc_1)) == Validation.trim(tostring(ScheduleItemFromArcos[j].desc_1))   
                     )  then
                        
                        --log_file:write(TIME_STAMP..'no changes for item :'..ScheduleItemFromArcos[j].ITEM_NUM,"\n") 
                        Logger.logInfo('no changes for item :'..ScheduleItemFromArcos[j].ITEM_NUM) 
                                                            
                     else   
                        
                                             --UpdateScheduleItems = ("update ArcosMDB.dbo.schedule_item Set ArcosMDB.dbo.schedule_item.lic_reqd =NULLIF('" ..tostring(ItemDataFromElite[i].lic_reqd).."',''), ArcosMDB.dbo.schedule_item.sched1 =NULLIF('" ..tostring(ItemDataFromElite[i].sched1).."',''), ArcosMDB.dbo.schedule_item.sched2 ='" ..tostring(ItemDataFromElite[i].sched2).."', ArcosMDB.dbo.schedule_item.sched3 ='" ..tostring(ItemDataFromElite[i].sched3).."', ArcosMDB.dbo.schedule_item.sched4 ='" ..tostring(ItemDataFromElite[i].sched4).."', ArcosMDB.dbo.schedule_item.sched5 ='"  ..tostring(ItemDataFromElite[i].sched5).."', ArcosMDB.dbo.schedule_item.sched6 ='" ..tostring(ItemDataFromElite[i].sched6).."', ArcosMDB.dbo.schedule_item.sched7 ='" ..tostring(ItemDataFromElite[i].sched7).."', ArcosMDB.dbo.schedule_item.sched8 ='" ..tostring(ItemDataFromElite[i].sched8).."',ArcosMDB.dbo.schedule_item.baccs =NULLIF('" ..tostring(ItemDataFromElite[i].BACCS).."',''), ArcosMDB.dbo.schedule_item.break_code ='" ..tostring(ItemDataFromElite[i].break_code).."', ArcosMDB.dbo.schedule_item.use_break_code ='" ..tostring(ItemDataFromElite[i].use_break_code).."', ArcosMDB.dbo.schedule_item.upc ='"..tostring(ItemDataFromElite[i].upc).."',ArcosMDB.dbo.schedule_item.row_update_stp =GETDATE(), ArcosMDB.dbo.schedule_item.row_update_user_id ='Iguana User' where  ArcosMDB.dbo.schedule_item.item_num ='"..tostring(ItemDataFromElite[i].ITEM_NUM).."'")
                                             UpdateScheduleItems = ("update ArcosMDB.dbo.schedule_item Set ArcosMDB.dbo.schedule_item.lic_reqd =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].lic_reqd)).. "', ''),''),'NULL'), ArcosMDB.dbo.schedule_item.sched1 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched1)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched2 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched2)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched3 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched3)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched4 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched4)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched5 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched5)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched6 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched6)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched7 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched7)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.sched8 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].sched8)).. "', ''),''), 'NULL'),ArcosMDB.dbo.schedule_item.baccs =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].baccs)).. "', ''),''),'NULL'), ArcosMDB.dbo.schedule_item.break_code =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].break_code)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.use_break_code =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].use_break_code)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.upc =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].upc)).. "', ''),''), 'NULL'), ArcosMDB.dbo.schedule_item.desc_1 =NULLIF(NULLIF(COALESCE('" ..Validation.trim(tostring(TabEliteDataCorrect[i].desc_1)).. "', ''),''), 'NULL'),ArcosMDB.dbo.schedule_item.row_update_stp =GETDATE(), ArcosMDB.dbo.schedule_item.row_update_user_id ='Iguana User' where  ArcosMDB.dbo.schedule_item.item_num ='"..Validation.trim(tostring(TabEliteDataCorrect[i].ITEM_NUM)).."'")                   
                                             ArcosDBConn:execute{sql=UpdateScheduleItems, live=true}
                     
                        --log_file:write(TIME_STAMP..'item :'..ScheduleItemFromArcos[j].ITEM_NUM.. ' updated in schedule_item table (ARCOS)',"\n")  
                        Logger.logInfo('item :'..ScheduleItemFromArcos[j].ITEM_NUM.. ' updated in schedule_item table (ARCOS)') 
                        
                     end
                     arcos_schedule_item = true
                     break
                 else       
                     arcos_schedule_item = false
                 end  --end if 31               
          end  -- for 2
          if (arcos_schedule_item == false or #ScheduleItemFromArcos == 0 ) then    --if 33
               
               InsertSQL=[[INSERT INTO ArcosMDB.dbo.schedule_item(
      item_num, 
      lic_reqd,
      sched1, 
      sched2, 
      sched3, 
      sched4, 
      sched5, 
      sched6, 
      sched7, 
      sched8, 
      baccs, 
      break_code,
      use_break_code, 
      upc,
      desc_1,
      row_add_stp,
      row_add_user_id,
      row_update_stp
                     
   ) 
      VALUES(']]
      ..TabEliteDataCorrect[i].item_num.."', '"
      ..TabEliteDataCorrect[i].lic_reqd.."', '"
      ..TabEliteDataCorrect[i].sched1.."', '"
      ..TabEliteDataCorrect[i].sched2.."', '"
      ..TabEliteDataCorrect[i].sched3.."', '"
      ..TabEliteDataCorrect[i].sched4.."', '"
      ..TabEliteDataCorrect[i].sched5.."', '"
      ..TabEliteDataCorrect[i].sched6.."', '"
      ..TabEliteDataCorrect[i].sched7.."', '"
      ..TabEliteDataCorrect[i].sched8.."', '"
      ..TabEliteDataCorrect[i].baccs.."', '"
      ..TabEliteDataCorrect[i].break_code.."', '"
      ..TabEliteDataCorrect[i].use_break_code.."', '"
      ..TabEliteDataCorrect[i].upc.."', '"
      ..TabEliteDataCorrect[i].desc_1.."',GETDATE(), 'Iguana User', GETDATE()"
      ..")"
          
         
               
               
       conn_Arcos_stg:execute{sql=InsertSQL, live=true}     
       --DatabaseConnection.executeSql(ARCOS_DB, InsertSQL, ARCOS_QUALIFIER)  
       
     log_file:write(TIME_STAMP..'item :'..ItemDataFromElite[i].ITEM_NUM..' inserted in schedule_item table (ARCOS) ',"\n")    
                
          end   --end if 33     
        end --for 1 
            
            
            else
                 log_file:write(TIME_STAMP..'Validation failed for elite data',"\n")  
            end
            else
           log_file:write(TIME_STAMP..'Error connecting ARCOS DB',"\n")    
                
            end   --end - Verify Arcos DB connection
        else
        log_file:write(TIME_STAMP..'Error connecting Elite DB',"\n") 
        end  --end - Verifying Elite DB connection
    
   log_file:write(TIME_STAMP..'Completed Elite Item Import Process',"\n\n")    
     --DatabaseConnection:close()
     
    log_file:write(TIME_STAMP..CHANNEL_STOPPED_RUNNING,"\n\n\n\n")
end  ---end main function


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
    log_file_with_today_date = "log_up "..os.date("%Y-%m-%d")..".txt" --lOG file name with Today Date
    print(log_file_with_today_date)
    local log_file_verify=io.open(output_log_path..log_file_with_today_date,'r')
    if log_file_verify~=nil then  --if 52
        io.close(log_file_verify)
        return io.open(output_log_path..log_file_with_today_date,'a+')
    else
        return io.open(output_log_path..log_file_with_today_date,'w')
    end  --end if 52
end  --end function getLogFile
