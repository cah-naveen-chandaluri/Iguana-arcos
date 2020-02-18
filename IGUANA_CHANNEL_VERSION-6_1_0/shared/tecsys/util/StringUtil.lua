-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

function node:S()
   return tostring(self)
end

function string:equals(value)
   
   if type(value) == 'number' then
      value = value:S()
   end
   
   return self == value
end

function string:isEmpty()
   return self:equals('')
end

function string:camelize()
   return string.upper(self:sub(1,1))..string.lower(self:sub(2))
end   

function string:startWith(text)
   return self:sub(1, string.len(text)) == text 
end   

function string:endWith(text)
   return self:sub(-string.len(text)) == text 
end   

function string:replaceAllWith(fromStr, toStr)
   return self:gsub(fromStr, toStr)
end   

function string:getBefore(str)
   local idx = self:find(str, 1, true)
   return self:sub(1, idx-1)
end   

function string:getAfter(str)
   local len = str:len()
   local idx = self:find(str, 1)
   return self:sub(idx+len)
end   

function string:escape()
  local escapeChars = {['<'] = '&lt;', ['>'] = '&gt;', ['"'] = '&quot;', ["'"] = '&apos;'}
  
  --The following substitution should be the first to avoid escaping another escaping chars
  self = self:gsub('&', '&amp;')
   
  for key,value in pairs(escapeChars) do 
      self = self:gsub(key, value)
  end    
  return self
end   

function string:dateParse(fmt)
   
   local t = dateparse.parse(self, fmt)
   
   return t and os.date("%Y-%m-%d", t)
end

function string:dateTimeParse(fmt)
   
   local t = dateparse.parse(self, fmt)
   
   return t and os.date("%Y-%m-%d %H:%M:%S", t)
end

--- Pads str to length len with char from right
string.lpad = function(str, len, char)
    if char == nil then char = ' ' end
    if str == nil then str = '' end
    return string.rep(char, len - #str) .. str 
end

--- Pads str to length len with char from left
string.rpad = function(str, len)
    char = ' '
    if str == nil then str = ' ' end
    return str..string.rep(char, len - #str) 
end

function node:V()
     if node.hasValue(self) then
      return self[1]:nodeValue()
   else
      return ''
   end    
end

function string:DS(fmt)
   local t = dateparse.parse(self, fmt)
   return t and os.date('%Y%m%d', t)
end

function string:OracleDT(fmt)
   local t = dateparse.parse(self, fmt)
   return t and os.date('%d-%b-%y', t)
end

function string:printObject( t )  

   local msg = ""
   local print_r_cache={}
   
   local function sub_print_r(t,indent)
      if (print_r_cache[tostring(t)]) then
         msg = msg..indent.."*"..tostring(t)
      else
         print_r_cache[tostring(t)]=true
         if (type(t)=="table") then
            for pos,val in pairs(t) do
               if (type(val)=="table") then
                  msg = msg.."\n"..indent.."["..pos.."] => "..tostring(t).." {"
                  sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                  msg = msg..indent..string.rep(" ",string.len(pos)+6).."}"
               elseif (type(val)=="string") then
                  msg = msg.."\n"..indent.."["..pos..'] => "'..val..'"'
               else
                  msg = msg.."\n"..indent.."["..pos.."] => "..tostring(val)
               end
            end
         else
            msg = msg..indent..tostring(t)
         end
      end
   end

   if (type(t)=="table") then
      msg = msg..tostring(t).." {"
      sub_print_r(t,"  ")
      msg = msg.."}"
   else
      sub_print_r(t,"  ")
   end
   
   return msg
end

function str( t )
   if isNilOrEmpty(t) then
      return ''
   elseif type(t) == 'string' then
      return t:trimWS()
   elseif type(t) == 'userdata' then
      return t:nodeValue():trimWS()
   else   
      return string:printObject(t)
   end   
end

