local util = {}
 ValidationFailedToInsertArcos={}
TotalRecordsInsertedPOStgTable = 0
CountValidationFailedToInsertArcos=0
function util.logic()
    if pcall(util.verifyDirectoryStatus) then  -- if 1             --this condition verifies whether log directory exist or not
        if pcall(dbConnection.verifyDBConnElite) then    --if 2    --this condition checks for the elite(oracle) database connection
            if pcall(dbConnection.verifyDBConnArcos) then  --if 3    --this condition checks about the arcos(sql server) database connection
                EliteData = conn_Elite_qa:execute{sql=SqlSelElite,live=true};   -- this will get data from elite
                print(#tostring(EliteData[1].CONFIRM_DATE))
                if(#EliteData>0) then   -- if 10
                    conn_Arcos_stg:execute{sql=SqlDeleteStgElitePoData,live=true}    -- executes query which deletes data from stg_elite_po_data table before insertion
                    SelResult=conn_Arcos_stg:query{sql=SqlSelStgElitePoData, live=true}    --executes select query which will help in checking the status of deletion                
                    if(#SelResult==0) then      --if 5                        
                        for i=1,#EliteData do    --for 7    -- this loop helps in inserting data into the stg_elit_po_data table
                         ValidStatus=validation.validationForOrderData(EliteData[i])    -- calls the validation function
                         if(ValidStatus==true) then   --if 16
                            LogFile:write(TIME_STAMP..VALIDATION_SUCCESS,"\n")
                            local DataSql=sqlQueries.beforeInsertion(EliteData,i)      --calls sqlQueries.Before_Insertion function
                            conn_Arcos_stg:execute{sql=DataSql, live=true}       --executes the insertion query which inserts data into stg_elite_po_data
                        TotalRecordsInsertedPOStgTable=TotalRecordsInsertedPOStgTable+1
                         else
                             LogFile:write(TIME_STAMP..VALIDATION_FAILED,"\n")                              
                             LogFile:write(TIME_STAMP.."Item_num which failed validation : "..EliteData[i].ITEM_NUM,"\n")
                         ValidationFailedToInsertArcos[CountValidationFailedToInsertArcos]=EliteData[i].ITEM_NUM
                        CountValidationFailedToInsertArcos=CountValidationFailedToInsertArcos+1 
                         end    --end if 16
                        end  	   --end for 7
                        SelRes1=conn_Arcos_stg:query{sql=SqlSelStgElitePoData, live=true}
                        if(#SelRes1>0) then    --if 15
                            conn_Arcos_stg:query{sql=SqlCompDelStgElitePoData, live=true}    -- executes the query which will do comparision
                            SelRes2=conn_Arcos_stg:query{sql=SqlSelStgElitePoData, live=true}  --query is used to check the status after comparision
                            if(#SelRes2>0 and #SelRes2<=#SelRes1) then   --if 11
                            conn_Arcos_stg:execute{sql=SqlInsTrnsctn, live=true}    --this query helps in inserting data into trnsctn table
                            else
                            LogFile:write(TIME_STAMP..INSERTION_FAILED,"\n")
                            end          --end if 11
                        else
                            LogFile:write(TIME_STAMP..COMPARE_FAILED,"\n")
                        end   --end if 15
                    else
                        LogFile:write(TIME_STAMP..DELETION_FAILED,"\n")
                        LogFile:write(TIME_STAMP..VALIDATION_FAILED,"\n")
                    end   --end if 5
                else
                   LogFile:write(TIME_STAMP..EMPTY_ELITE_DATA,"\n")
                end    --end if 10                                -- here we are calling the function util.logic2
        else
            LogFile:write(TIME_STAMP..DB_CON_ERROR_ARCOS_STG,"\n")
        end   --end if 3
    else
        LogFile:write(TIME_STAMP..DB_CON_ERROR_ELITE,"\n")
    end  --end if 2
    else
        LogFile:write(TIME_STAMP..LOG_DIR_MISS,"\n")
    end  --end if 1
   

   if( CountValidationFailedToInsertArcos > 0) then
      LogFile:write('Total Records failed in validation to insert in ARCOS : '..CountValidationFailedToInsertArcos,"\n")
   end
   
   
   if(TotalRecordsInsertedPOStgTable > 0) then
     LogFile:write('Total records inserted in the Schedule Item table in ARCOS : '..TotalRecordsInsertedPOStgTable,"\n")
   end
    

   LogFile:write('Completed Elite Item Import Process') 
    LogFile:write(TIME_STAMP..CHANNEL_STOPPED_RUNNING,"\n\n")
end


function util.verifyDirectoryStatus()  --function for verifying directory status

    if(result_LogDirectory_Status==false)   then  --if 99  -- checking for directory exist or not
        LogFile:write(TIME_STAMP..LOG_DIR_MISS,"\n") --checking
        os.fs.mkdir(OutputLogPath)
        LogFile:write(TIME_STAMP..LOG_DIR_CREATE,"\n") --checking
        ResultLogFileDirectoryStatus=os.fs.access(OutputLogPath)
end  --end if 99
end   --end verify_Directory_Status()


function util.getLogFile(OutputLogPath)  -- function getLogFile
    ResultLogFileDirectoryStatus=os.fs.access(OutputLogPath)
    if(ResultLogFileDirectoryStatus==false) then  --if 51 -- checking for directory exist or not
        os.fs.mkdir(OutputLogPath)
    end   --end if 51
    LogFileWithTodayDate = "log_Arcos_Channel_2 "..os.date("%Y-%m-%d")..".txt" --lOG file name with Today Date
    print(LogFileWithTodayDate)
    local LogFileVerify=io.open(OutputLogPath..LogFileWithTodayDate,'r')
    if LogFileVerify~=nil then  --if 52
        io.close(LogFileVerify)
        return io.open(OutputLogPath..LogFileWithTodayDate,'a+')
    else
        return io.open(OutputLogPath..LogFileWithTodayDate,'w')
    end  --end if 52
end  --end function getLogFile


return util

