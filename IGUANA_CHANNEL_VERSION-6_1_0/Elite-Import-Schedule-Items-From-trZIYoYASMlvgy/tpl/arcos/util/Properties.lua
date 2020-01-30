local Properties =  {}

local dbConnection = require "tpl.arcos.db.DatabaseConnection"
dbConnection.connectdb()

function Properties.db_conn()
   db_elite_conn = conn_elite_dev
   db_arcos_conn = conn_arcos_stg
end

output_log_path= "C:\\ARCOS\\LogFiles\\"

return Properties
