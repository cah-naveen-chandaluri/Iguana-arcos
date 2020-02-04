local Validation =  {}

function Validation.validate_value_string(order_value,column_size) --validation of data present in order files
   print(type(order_value),#order_value)
   print(type(order_value:nodeText()),#order_value,#order_value:nodeText(),type(order_value:nodeText()))
      if(order_value == nil) then
	        return true
      elseif(type(order_value)=='userdata' and #order_value<=column_size and #order_value>=0) then
         return true
      else
         return false
      end
end 


function Validation.validate_value_string2(order_value) --validation of data present in order files
      if(order_value == nil) then
	        return true
      elseif(type(order_value)=='userdata') then
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