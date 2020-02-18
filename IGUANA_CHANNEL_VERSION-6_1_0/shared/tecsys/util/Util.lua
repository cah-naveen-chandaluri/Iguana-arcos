-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.
require 'dateparse'

local live = false

function isNilOrEmpty(object)

   if type(object) == 'nil' or object == 'nil' or object == json.NULL then
      return true
   end

   if type(object) == 'string' then
      return object == ''
   end

   if type(object) == 'table' then
      if next(object) == nil then
         return true
      end
      return false
   end

   return false
end

function isTrue(object)
   if type(object) == 'nil' then
      return false
   end

   if type(object) == 'string' then
      return object:lower() == 'true' or object == '1'
   end

   if type(object) == 'number' then
      return object == 1
   end
end

function iif( cond , T , F )
   if cond then return T else return F end
end

function isProduction()
   if isNilOrEmpty(iguana.appDir():find('prod')) then
      return false
   end   

   return true
end   

function isLive()
   return not iguana.isTest() or live
end   

function setLive(flag)
   live = flag
end   

function isStringType(value)
   return type(value) == 'string'
end   

function map (field, value, escape)
   if isNilOrEmpty(value) then return end

   local success, errorInfo = pcall(
      function()
         if isNilOrEmpty(escape) or escape then
            field:setInner("<![CDATA["..value.."]]>")
         else   
            field:setInner(value)
         end   
      end
   )
   
   if not success then
      Logger.logError{Message="Mapping error has occur.", errorInfo}
   end   
end

-----------------------------------------------------
-- Additional functions to generic node 
-----------------------------------------------------

-- reutrn true and position if Node has a child node with name childNodeName
function node.hasChild(Node, childNodeName)
   for i=1, #Node do
      if Node[i]:nodeName() == childNodeName then 
         return true, i
      end
   end
   return false, 0
end

-- return a child node with childNodeName
function node.getChild(Node, childNodeName)
   for i=1, #Node do
      if Node[i]:nodeName() == childNodeName then 
         return Node[i]
      end
   end
   return nil
end

--Test if a xml node is empty tag (no value) ex. <book></book>
function node.hasValue(Node)
   return Node:childCount() ~= 0
end

-- removes all empty xml tags and return the result
function node.removeNullTags(xmlValue) 
   local xmlLineNodeTree = xml.parse{data=xmlValue} 
   local lineNode = xmlLineNodeTree[1]
   for i=lineNode:childCount(),1,-1 do
      if lineNode[i]:childCount() == 0 then
         lineNode:remove(i)
      end   
   end   

   return xmlLineNodeTree:S()
end

function node.removeEmptyChildNode(xmlNode, excludeList) 

   --excludeList should be nil or table type. Table contains a list of altIdentifiers
   assert(excludeList == nil or type(excludeList) == 'table')

   for i=xmlNode:childCount(),1,-1 do

      --Visit child node recursively
      local remove = true
      if not isNilOrEmpty(excludeList) then
         for j = 1, #excludeList do
            if xmlNode[i]:nodeName() == excludeList[j] then
               remove = false
               break;
            end  
         end
      end   

      if remove then
         node.removeEmptyChildNode(xmlNode[i]) 

         if not xmlNode[i]:isLeaf() and xmlNode[i]:childCount() == 0 then
            xmlNode:remove(i)
         end   
      end
   end   

   return xmlNode
end

--root: root node
--pathElement: table contains path elements
--Example: 
--local xmlbody = "<a><b><c></c></b></a>"
--   local path = "a/b/c"
--   local root = xml.parse{data=xmlbody}
--   root:getNodeByPath(path:split("/")):setInner("123")
function node.getNodeByPath(root, pathElements)
   
   --Check if the child element exists
   if isNilOrEmpty(root:getChild(pathElements[1])) then
      return nil
   end   
   
   local currentElement = root:child(pathElements[1])
   if isNilOrEmpty(currentElement) then return nil end

   -- remove the current path element
   table.remove(pathElements, 1)
   if table.length(pathElements) == 0 then
      return currentElement
   else
      return node.getNodeByPath(currentElement, pathElements)
   end
end   

-- return a number of elements in a table T
function table.length(T)
   local count = 0
   for _ in pairs(T) do count = count + 1 end
   return count
end


function table.contains(table, element)

   for _, value in pairs(table) do
      if value == element then
         return true
      end
   end

   return false
end

function table.containsKey(table, element)
   return table[element] ~= nil
end

function table.copy(sourceTable, copyNestedTable)
   if type(sourceTable) ~= 'table' then return sourceTable end
   local res = {}

   for k, v in pairs(sourceTable) do 
      if type(v) == 'table' then
         if copyNestedTable then
            res[table.copy(k)] = table.copy(v) 
         end   
      else
         res[table.copy(k)] = table.copy(v) 
      end   
   end

   return res
end

-- rec: table with elements
-- separator. ex. '\t', ','
function table.delimitedString(rec, seperator)
   local str = ''

   if (#rec > 0) then
      str = rec[1][1]:nodeValue()
      for i = 2, #rec[1] do
         str = str..seperator..rec[1][i]:nodeValue()
      end  
   end   

   return str
end

-- Example.
--   local xmlNode = xml.parse{data=x}
--   local t={}
--   t[1]=''
--   t[2]=xmlNode.DmsTerritoryMaster.CreatedOn:nodeText()
--   t[3]=''
--   t[4]=xmlNode.DmsTerritoryMaster.Description1:nodeText()
--   t[5]=xmlNode.DmsTerritoryMaster.CreatedBy:nodeText()
--   local str = table.getDelimitedList(t, '|')
function table.getDelimitedList(t, sep, addNewLine, lineTag)

   -- set default separator if not given
   sep = iif(isNilOrEmpty(sep), ',', sep)
   
   local newLine = iif (addNewLine, '\n', '')
   local list = ''
   for k, v in table.pairsByKeys(t) do
      list = list..v..sep
   end

   if isNilOrEmpty(lineTag) then
      return list:sub(1, list:len()-1)..newLine
   end

   return lineTag..sep..list:sub(1, list:len()-1)..newLine
end 

function table.pairsByKeys (t, f)
   local a = {}
   for n in pairs(t) do table.insert(a, n) end
   table.sort(a, f)
   local i = 0      -- iterator variable
   local iter = function ()   -- iterator function
      i = i + 1
      if a[i] == nil then return nil
      else return a[i], t[a[i]]
      end
   end
   return iter
end

-- USAGE
--   local dataNode = xml.parse{data=xmlString}
--   local resultJson = xml.getJson(dataNode)
function xml.getJson(dataNode, result, depth, parentNode, idx)
   
   function indent(depth)
      return string.rep(' ', 3*depth)
   end   
   
   local function inRepeatingBlock(dataNode, idx)
      if dataNode == nil or dataNode:childCount() == 1 then return false end

      if idx == dataNode:childCount() then
         return dataNode[idx]:nodeName() == dataNode[idx-1]:nodeName()
      elseif idx == 1 then   
         return dataNode[1]:nodeName() == dataNode[idx+1]:nodeName()
      end   

      return (dataNode[idx]:nodeName() == dataNode[idx-1]:nodeName()) or
      (dataNode[idx]:nodeName() == dataNode[idx+1]:nodeName())
   end 

   local function startRepeating(dataNode, idx)
      if dataNode ~= nil and idx < dataNode:childCount() then  
         if idx == 1 then
            return dataNode[idx]:nodeName() == dataNode[idx+1]:nodeName()
         else
            return (dataNode[idx]:nodeName() == dataNode[idx+1]:nodeName()) and
            (dataNode[idx]:nodeName() ~= dataNode[idx-1]:nodeName())
         end   
      end
    
      return false
   end   

   local function endRepeating(dataNode, idx)
      if dataNode ~= nil and dataNode:childCount() > 1 then
         if idx == dataNode:childCount() then 
            return dataNode[idx]:nodeName() == dataNode[idx-1]:nodeName()
         elseif idx > 1 then 
            return dataNode[idx]:nodeName() == dataNode[idx-1]:nodeName() and
            (dataNode[idx]:nodeName() ~= dataNode[idx+1]:nodeName())
         end   
      end
    
      return false
   end   
   
   local function newLine(parentNode, idx)
      return iif(parentNode ~= nil and parentNode:childCount() > idx, ',\n', '\n')
   end
  
   if parentNode == nil then result = '{\n'; dataNode = dataNode[1]; depth = 1 end  

   if (dataNode:childCount() == 0) or 
      (dataNode:childCount() == 1 and dataNode[1]:isLeaf()) then
      local value = iif(node.isLeaf(dataNode),dataNode:S(), string.gsub(dataNode:nodeText(), '"', '\\"'))
      result = result..indent(depth)..'"'..dataNode:nodeName()..'": "'..value..'"'..newLine(parentNode, idx)
   else 

      if startRepeating(parentNode, idx) then
         result = result..indent(depth)..'"'..dataNode:nodeName() ..'": [\n'
      end
      local isRepating = inRepeatingBlock(parentNode, idx)
      if isRepating then
         result = result..indent(depth+1)..'{\n'
      else
         result = result..indent(depth)..'"'..dataNode:nodeName()..'": {\n'
      end

      for i = 1, dataNode:childCount() do
         result = xml.getJson(dataNode[i], result, depth+1, dataNode, i)
      end  

      if endRepeating(parentNode, idx) then 
         result = result..indent(depth+iif(depth == 1, 0, 1))..'}\n'
         result = result..indent(depth)..']'..newLine(parentNode, idx)
      else   
         result = result..indent(depth+iif(isRepating, 1, 0))..'}'..newLine(parentNode, idx)
      end
   end

   if depth == 1 then result = result..'}' end

   return result
end

function calcualteDateTime(numYr, numMonth, numDay, dateOnly)
   
   --retrieve current date parameters
   local today = os.date('*t') 
   -- retrieve date as epoch time
   local cTime = os.ts.time() 
   --calculate difference of time based on supplied days (i.e. 7 days)
   local timeDiff = os.ts.difftime(cTime, os.ts.time{year  = today.year+numYr, 
                                                    month = today.month+numMonth, 
                                                    day   = today.day+numDay, 
                                                    hour  = today.hour, 
                                                    min   = today.min, 
                                                    sec   = today.sec,})
   if dateOnly then
      return  os.ts.date('%Y-%m-%d', cTime - timeDiff)
   end
   
   return  os.ts.date('%Y-%m-%d %H:%M:%S', cTime - timeDiff)
end

function getMessageUrl()
   if isNilOrEmpty(iguana['messageId']) then return '' end   
   local info = iguana.webInfo()
   local protocol = iif(info.web_config.use_https, 'https', 'http')
   return 'Message URL: '..protocol..'://'..info.host..':'..info.web_config.port..'/log_browse?refid='..iguana.messageId()..'\n'
end 

-- startTime and getElapsedTime works together
--------------------------------------------------------------------------------------------------------------
function startTime(tag)
   if isNilOrEmpty(tag) then tag = '' end
   local start_time = os.time()
   iguana.logDebug('Execution started at '..tostring(start_time)..'\nExecution tag: '..tag)
   
   return {StartTime=start_time, Message=tag}
end

function endTime(param, endMsg)
   
   if isNilOrEmpty(endMsg) then endMsg = '' end
   local current = os.time()
   iguana.logDebug('Execution ended at '..tostring(current)
      ..' and ran for '..os.difftime(current, param.StartTime)..' secconds.'..endMsg..'\nExecution tag: '..param.Message)
end 
--------------------------------------------------------------------------------------------------------------