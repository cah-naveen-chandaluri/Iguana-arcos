-- The main function is the first function called from Iguana.
function main()

    Constants = require("Constants")
    Validation = require("Validation")
    Procedure=require("Stored_Procedures")
    dbConnection = require("DBConnection")
    util = require("util")
    --Properties = require("Properties")
    dbConnection.connectdb()
    Constants.csos_order_header_size()
    Procedure.firstProcedure()
   Procedure.delProcedure()
   Procedure.insProcedure()
    -- Properties.directory_path()
    -- Properties.db_conn()

   
    tab_elite_data_correct={}
    tab_elite_data_wrong={}
    Insert_Result={}
    Sel_res={}
   
   
    log_file = util.getLogFile(output_log_path)    --calling the geLogFile function
    log_file:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")
    util.logic()
   
end  ---end main function




          


   