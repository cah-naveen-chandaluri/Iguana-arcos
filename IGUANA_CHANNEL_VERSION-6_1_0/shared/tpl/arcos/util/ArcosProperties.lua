local Properties =  {}

local dbConnection = require "tpl.arcos.db.ArcosDatabaseConnection"
dbConnection.connectdb()

function Properties.db_conn()
   EliteOraclDbConn = EliteDBConn
   ArcosSQLDbConn = ArcosDBConn
end



return Properties
