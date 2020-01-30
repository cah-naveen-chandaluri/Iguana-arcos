properties = require("tpl.arcos.util.Properties")
validation = require("tpl.arcos.util.validation")
elite_sql_queries = require("tpl.arcos.sql.EliteSqlQueries")
arcos_sql_queries = require("tpl.arcos.sql.ArcosSqlQueries")
Constants = require("tpl.arcos.util.Constants")
  
properties.db_conn()
Constants.constant_values()
elite_sql_queries.export_schedule_item()   
arcos_sql_queries.export_schedule_item()
-- The main function is the first function called from Iguana.
function main()
    
    if pcall(verify_log_directory_status) then  -- Validating log directory
        log_file = getLogFile(output_log_path)
        log_file:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")
        if pcall(Verify_DBConn_Elite) then  -- Verifying Elite DB connection
            if pcall(Verify_DBConn_Arcos) then -- Verify Arcos DB connection
            -- Exporting the schedule items from elite
            export_schedule_items_from_elite = db_elite_conn:query{sql=exportScheduleItemsFromElite,live=true};
            -- Exporting the schedule items from arcos
            export_schedule_items_from_arcos = db_arcos_conn:query{sql =exportScheduleItemsFromArcos,live=true};
            --db_arcos_conn:close()
            --db_elite_conn:close()
            for i=1,#export_schedule_items_from_elite do
               arcos_schedule_item = true
               for j=1,#export_schedule_items_from_arcos do   
                 if(trim(tostring(export_schedule_items_from_elite[i].ITEM_NUM)) == trim(tostring(export_schedule_items_from_arcos[j].ITEM_NUM))) then
                     if(trim(tostring(export_schedule_items_from_elite[i].LIC_REQD)) == trim(tostring(export_schedule_items_from_arcos[j].lic_reqd)) and
                     -- export_schedule_items_from_elite[i].DEA_SCHEDULE_LIST == export_schedule_items_from_arcos[j].DEA_Schedule_List and
                     -- export_schedule_items_from_elite[i].LICENSE_TYPE == export_schedule_items_from_arcos[j].License_type and 
                     trim(tostring(export_schedule_items_from_elite[i].BACCS)) == trim(tostring(export_schedule_items_from_arcos[j].baccs)) and
                     trim(tostring(export_schedule_items_from_elite[i].BREAK_CODE)) == trim(tostring(export_schedule_items_from_arcos[j].break_code)) and 
                     trim(tostring(export_schedule_items_from_elite[i].UPC)) == trim(tostring(export_schedule_items_from_arcos[j].upc)) and
                     trim(tostring(export_schedule_items_from_elite[i].USE_BREAK_CODE)) == trim(tostring(export_schedule_items_from_arcos[j].use_break_code)) and
                     trim(tostring(export_schedule_items_from_elite[i].DESC_1)) == trim(tostring(export_schedule_items_from_arcos[j].desc_1)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED1)) == trim(tostring(export_schedule_items_from_arcos[j].sched1)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED2)) == trim(tostring(export_schedule_items_from_arcos[j].sched2)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED3)) == trim(tostring(export_schedule_items_from_arcos[j].sched3)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED4)) == trim(tostring(export_schedule_items_from_arcos[j].sched4)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED5)) == trim(tostring(export_schedule_items_from_arcos[j].sched5)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED6)) == trim(tostring(export_schedule_items_from_arcos[j].sched6)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED7)) == trim(tostring(export_schedule_items_from_arcos[j].sched7)) and
                     trim(tostring(export_schedule_items_from_elite[i].SCHED8)) == trim(tostring(export_schedule_items_from_arcos[j].sched8))
                     -- export_schedule_items_from_elite[i].CONTR_SUBST == export_schedule_items_from_arcos[j].contr_subst      
                     )  then
                          log_file:write(TIME_STAMP.."        for ITEM_NUM"..export_schedule_items_from_arcos[j].ITEM_NUM.."there is no change in Arcosdatabase","\n")                                    
                     else   
                          SqlUpdate=("Update ArcosMDB.dbo.ScheduleItems Set lic_reqd='"..trim(tostring(export_schedule_items_from_elite[i].LIC_REQD)).."',baccs ='"..trim(tostring(export_schedule_items_from_elite[i].BACCS)).."',break_code ='"..trim(tostring(export_schedule_items_from_elite[i].BREAK_CODE)).."',use_break_code ='"..trim(tostring(export_schedule_items_from_elite[i].USE_BREAK_CODE)).."',upc ='"..trim(tostring(export_schedule_items_from_elite[i].UPC)).."',desc_1 ='"..trim(tostring(export_schedule_items_from_elite[i].DESC_1)).."',sched1 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED1)).."',sched2 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED2)).."',sched3 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED3)).."',sched4 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED4)).."',sched5 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED5)).."',sched6 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED6)).."',sched7 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED7)).."',sched8 ='"..trim(tostring(export_schedule_items_from_elite[i].SCHED8)).."' Where item_num ='"..trim(tostring(export_schedule_items_from_arcos[j].ITEM_NUM)).."'")
                          db_arcos_conn:execute{sql=SqlUpdate, live=true}
                          --db_arcos_conn:close()
                          log_file:write(TIME_STAMP.."        for ITEM_NUM : "..export_schedule_items_from_arcos[j].ITEM_NUM.."there needs to be some updation done in Arcos database","\n")                           
                     end
                     arcos_schedule_item = true
                     break
                 else       
                     arcos_schedule_item = false
                 end  --end if 31               
          end  -- for 2
          if (arcos_schedule_item == false) then    --if 33
                  SqlInsert=("INSERT INTO ArcosMDB.dbo.ScheduleItems(item_num, lic_reqd, baccs, break_code, use_break_code, upc, desc_1, sched1, sched2, sched3, sched4, sched5, sched6, sched7, sched8) VALUES ('"..trim(tostring(export_schedule_items_from_elite[i].item_num)).."','"..trim(tostring(export_schedule_items_from_elite[i].lic_reqd)).."','"..trim(tostring(export_schedule_items_from_elite[i].baccs)).."','"..trim(tostring(export_schedule_items_from_elite[i].break_code)).."','"..trim(tostring(export_schedule_items_from_elite[i].use_break_code)).."','"..trim(tostring(export_schedule_items_from_elite[i].upc)).."','"..trim(tostring(export_schedule_items_from_elite[i].desc_1)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched1)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched2)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched3)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched4)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched5)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched6)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched7)).."','"..trim(tostring(export_schedule_items_from_elite[i].sched8)).."')")
                  --SqlInsert=("select * from ArcosMDB.dbo.ScheduleItems")
                  db_arcos_conn:execute{sql=SqlInsert}
                -- db_arcos_conn:query{sql ="INSERT INTO ScheduleItems ( item_num, lic_reqd, baccs, break_code, use_break_code, upc, desc_1, sched1, sched2, sched3, sched4, sched5, sched6, sched7, sched8 );",live=true};                
                log_file:write(TIME_STAMP.."  for ITEM_NUM : "..export_schedule_items_from_elite[i].ITEM_NUM.."there needs to be some insertion done in Arcos database","\n")  
          end   --end if 33     
        end --for 1 
            else
                log_file:write(TIME_STAMP..DB_CON_ERROR_ARCOS_STG,"\n")
            end   --end - Verify Arcos DB connection
        else
            log_file:write(TIME_STAMP..DB_CON_ERROR_ELITE,"\n")
        end  --end - Verifying Elite DB connection
    else
        log_file:write(TIME_STAMP..LOG_DIR_MISS,"\n")
    end  --end - Validating log directory
    log_file:write(TIME_STAMP..CHANNEL_STOPPED_RUNNING,"\n\n")
end  ---end main function