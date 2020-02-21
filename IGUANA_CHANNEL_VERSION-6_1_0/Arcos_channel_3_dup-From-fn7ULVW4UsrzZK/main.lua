-- The main function is the first function called from Iguana.
function main()

    constants = require("Constants")
    validation = require("Validation")
    dbConnection = require("DBConnection")
    util = require("util")
    sqlQueries=require("sqlQueries")
   
   
   
    dbConnection.connectdb()
    dbConnection.verifyDBConnElite()
    dbConnection.verifyDBConnArcos()
    constants.eliteSize()
    constants.logConstants()
    sqlQueries.queries()
       

    TabEliteDataCorrect={}
    TabEliteDataWrong={}



    LogFile = util.getLogFile(OutputLogPath)    --calling the geLogFile function
    LogFile:write(TIME_STAMP..CHANNEL_STARTED_RUNNING,"\n")
    util.logic()    --calling logic function

end  ---end main function




          


   