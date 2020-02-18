local SalesValidation =  {}

function SalesValidation.validateValueString(OrderValue,ColumnSize) --validation for data that we got from elite
   print(type(OrderValue),#OrderValue)
   print(type(OrderValue:nodeText()),#OrderValue,#OrderValue:nodeText(),type(OrderValue:nodeText()))
   if(type(OrderValue)=='userdata' and #OrderValue<=ColumnSize and #OrderValue>=0 ) then
      return true
   else
      return false
   end
end


-- Validating the order data
function SalesValidation.validationForOrderData(EliteData)    -- this function will helps in validating data

end  --end validationForOrderData() function


return SalesValidation