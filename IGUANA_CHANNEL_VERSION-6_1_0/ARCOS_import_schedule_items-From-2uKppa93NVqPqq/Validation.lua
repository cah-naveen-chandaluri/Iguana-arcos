local Validation =  {}



function Validation.Verify_DBConn_Elite()  --function for validating db connection
    return conn_Elite_qa:check()
end  --end Verify_DBConn_Elite() function



function Validation.Verify_DBConn_Arcos()  --function for validating db connection
    return conn_Arcos_stg:check()
end  --end Verify_DBConn_Arcos() function


function Validation.rtrim(s)
  return s:match'^(.*%S)%s*$'
end

function Validation.trim(s)
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end


function Validation.validateValueString(OrderValue,ColumnSize) --validation for data that we got from elite
   if(type(OrderValue)=='userdata' and #OrderValue<=ColumnSize and #OrderValue>=0 ) then
      return true
   else
      return false
   end
end


function Validation.validationForScheduleItemData(ItemDataFromElite)    -- this function will helps in validating data

   local ValidateionStatus = false
   for i=1,#ItemDataFromElite do
      if(  --if 21
            Validation.validateValueString(ItemDataFromElite[i].item_num,30)   --if 11
            and Validation.validateValueString(ItemDataFromElite[i].lic_reqd,1)  --need to check
            and Validation.validateValueString(ItemDataFromElite[i].sched1,1)  --need to check
            and Validation.validateValueString(ItemDataFromElite[i].sched2,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched3,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched4,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched5,1)  --need to check  -- size is 38
            and Validation.validateValueString(ItemDataFromElite[i].sched6,1)  --need to check -- size is 38
            and Validation.validateValueString(ItemDataFromElite[i].sched7,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched8,1)
            and Validation.validateValueString(ItemDataFromElite[i].baccs,1)
            and Validation.validateValueString(ItemDataFromElite[i].break_code,4)
            and Validation.validateValueString(ItemDataFromElite[i].use_break_code,1)
            and Validation.validateValueString(ItemDataFromElite[i].upc,15)
            and Validation.validateValueString(ItemDataFromElite[i].desc_1,70)

         )then
         ValidateionStatus = true

         TabEliteDataCorrect[i]=ItemDataFromElite[i]

      else
         ValidateionStatus = false
         TabEliteDataWrong[i]=ItemDataFromElite[i]
      end --end if 21

   end  --end for
   return ValidateionStatus
   
end  --end validationForOrderData() function


return Validation