properties = require("tpl.arcos.util.Properties")

properties.db_conn()
   
function Verify_DBConn_Elite()  --function for validating db connection
    return db_elite_conn:check()
end  --end Verify_DBConn_Elite() function


function Verify_DBConn_Arcos()  --function for validating db connection
    return db_arcos_conn:check()
end  --end Verify_DBConn_Arcos() function

function rtrim(s)
  return s:match'^(.*%S)%s*$'
end

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function verify_log_directory_status()  --function for verifying directory status
    if(result_LogDirectory_Status==false)   then   -- checking for directory exist or not   --if 99
        log_file:write(TIME_STAMP..LOG_DIR_MISS,"\n") --checking
        os.fs.mkdir(output_log_path)
        log_file:write(TIME_STAMP..LOG_DIR_CREATE,"\n") --checking
        result_LogDirectory_Status=os.fs.access(output_log_path)
    end
end   --end verify_Directory_Status() function

function getLogFile(output_log_path)  -- function getLogFile
    result_LogFileDirectory_Status=os.fs.access(output_log_path)
    if(result_LogFileDirectory_Status==false) then  --if 51 -- checking for directory exist or not
        os.fs.mkdir(output_log_path)
    end   --end if 51
    log_file_with_today_date = "logsss_import_schedule_items_ "..os.date("%Y-%m-%d")..".txt" --lOG file name with Today Date
    local log_file_verify=io.open(output_log_path..log_file_with_today_date,'r')
    if log_file_verify~=nil then  --if 52
        io.close(log_file_verify)
        return io.open(output_log_path..log_file_with_today_date,'a+')
    else
        return io.open(output_log_path..log_file_with_today_date,'w')
    end  --end if 52
end  --end function getLogFile