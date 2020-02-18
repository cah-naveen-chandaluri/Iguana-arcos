properties = require("tpl.arcos.util.ArcosProperties")

properties.db_conn()
   


function Verify_DBConn_Elite()  --function for validating db connection
    return EliteDBConn:check()
end  --end Verify_DBConn_Elite() function


function Verify_DBConn_Arcos()  --function for validating db connection
    return EliteDBConn:check()
end  --end Verify_DBConn_Arcos() function

function rtrim(s)
  return s:match'^(.*%S)%s*$'
end

function trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function validateDataValue(value, dataType, columnSize) --validation for data that we got from elite
   if(type(value)==dataType and #value<=ColumnSize and #value>=0 ) then
       return true
    else
        return false
    end
end

---------------  Elit-ARCOS - ImportScheduleItem - Validation ----------------------------

-- Validating the data before inserting into the schedule_item table in ARCOS MDB 
function validationForScheduleItemData(ItemDataFromElite)    -- this function will helps in validating data

        if( validateDataValue(validateNullValue(ItemDataFromElite.item_num),"string",30)
            and validateDataValue(ItemDataFromElite.lic_reqd, "string",1)
            and validateDataValue(ItemDataFromElite.sched2, "string",1)
            and validateDataValue(ItemDataFromElite.sched3, "string",1)
            and validateDataValue(ItemDataFromElite.sched4, "string",1)
            and validateDataValue(ItemDataFromElite.sched5, "string",1)
            and validateDataValue(ItemDataFromElite.sched6, "string",1)
            and validateDataValue(ItemDataFromElite.sched7, "string",1)
            and validateDataValue(ItemDataFromElite.sched8, "string",1)
            and validateDataValue(ItemDataFromElite.baccs, "string",1)
            and validateDataValue(ItemDataFromElite.break_code, "string",4)
            and validateDataValue(ItemDataFromElite.use_break_code, "string",1)
            and validateDataValue(ItemDataFromElite.upc, "string",15)
            and validateDataValue(ItemDataFromElite.desc_1, "string",70)
            )then
      
            return true
        else
	         return false
        end
end
