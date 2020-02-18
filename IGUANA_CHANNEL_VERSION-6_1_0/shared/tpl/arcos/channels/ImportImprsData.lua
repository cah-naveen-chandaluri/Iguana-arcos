local Properties = require("tpl.arcos.util.ArcosProperties")
local Validation = require("tpl.arcos.util.Arcosvalidation")
local POValidation = require("tpl.arcos.util.POValidation")
local ImprsValidation = require("tpl.arcos.util.ImprsValidation")
local ImprsEliteSQL = require("tpl.arcos.sql.ImprsEliteSQL")
local ImprsArcosSQL = require("tpl.arcos.sql.ImprsArcosSQL")
local Constant = require("tpl.arcos.util.ArcosConstant")

Properties.db_conn()
Constant.constant_values()
Constant.eliteSize()
TabEliteDataCorrect={}
TabEliteDataWrong={}
local ImportImprsData = {}
local this = {}

function ImportImprsData.importImprsDataFromElite()


   


end 
return ImportImprsData
