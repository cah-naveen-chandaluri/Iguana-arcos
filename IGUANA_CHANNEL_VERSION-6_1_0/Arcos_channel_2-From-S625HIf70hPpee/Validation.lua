local Validation =  {}
function Validation.validate_value_string(order_value,column_size) --validation of data present in order files
      if(order_value == nil) then
	        return false
      elseif(type(order_value:nodeText())=='string' and #order_value<=column_size and #order_value>=0) then
         return true
      else
         return false
      end
end 




function Validation.validate_value_num(order_value,column_size) --validation of data present in order files
      if(order_value == nil) then
	        return false
      elseif(type(order_value:nodeText())=='number' and #order_value<=column_size and #order_value>=0) then
         return true
      else
         return false
      end
end

function Validation.validate_value_userdata(order_value) --validation of data present in order files
      if(order_value == nil) then
	        return false
      elseif(type(order_value:nodeText())=='userdata') then
         return true
      else
         return false
      end
end

return Validation