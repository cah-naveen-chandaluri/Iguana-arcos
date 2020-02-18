local Properties = require("tpl.arcos.util.ArcosProperties")
local Validation = require("tpl.arcos.util.Arcosvalidation")
local POValidation = require("tpl.arcos.util.POValidation")
local SalesValidation = require("tpl.arcos.util.SalesValidation")
local SalesEliteSQL = require("tpl.arcos.sql.SalesEliteSQL")
local SalesArcosSQL = require("tpl.arcos.sql.SalesArcosSQL")
local Constant = require("tpl.arcos.util.ArcosConstant")

Properties.db_conn()
Constant.constant_values()
Constant.eliteSize()
TabEliteDataCorrect={}
TabEliteDataWrong={}
local ImportSalesData = {}
local this = {}

function ImportSalesData.importSalesDataFromElite()





end 
return ImportSalesData