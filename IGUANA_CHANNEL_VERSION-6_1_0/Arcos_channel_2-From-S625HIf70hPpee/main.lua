-- The main function is the first function called from Iguana.
function main()

    constants = require("Constants")
    validation = require("Validation")
    procedure=require("Stored_Procedures")
    dbConnection = require("DBConnection")
    util = require("util")
    sqlQueries=require("sqlQueries")
   
   
    dbConnection.connectdb()
    dbConnection.verify_DBConn_Elite()
    dbConnection.verify_DBConn_Arcos()
    constants.elite_size()
    constants.log_Constants()
    procedure.firstProcedure()
    procedure.delProcedure()
    procedure.insProcedure()
    sqlQueries.queries()
    
    

    tab_elite_data_correct={}
    tab_elite_data_wrong={}
    Insert_Result={}
    Sel_res={}


    log_file = util.getLogFile(output_log_path)    --calling the geLogFile function
    log_file:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")
    util.logic()    --calling logic function

end  ---end main function




          


   