local ArcosSqlQueries = {}

properties = require("tpl.arcos.util.Properties")
properties.db_conn()

function ArcosSqlQueries.export_schedule_item()

 exportScheduleItemsFromArcos = [[ SELECT * FROM ArcosMDB.dbo.ScheduleItems]]

end


return ArcosSqlQueries