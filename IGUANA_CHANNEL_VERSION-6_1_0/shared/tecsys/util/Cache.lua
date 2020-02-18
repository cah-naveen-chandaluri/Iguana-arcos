-- Copyright © 2018 TECSYS Inc. All rights reserved.
-- Copyright © 2018 TECSYS Inc. Tous droits réservés.
-- The Cache module

local Cache = {}
local cacheId

-- use to create connection object when needed
local function connCreate()
   trace(cacheId)
   return db.connect{api=db.SQLITE, name=cacheId..".cache"}
end

-- This function returns the state of the entity table by performing a general select
-- query on it.
function Cache.getTableState()
   local conn = connCreate()
   local R = conn:query ("SELECT * FROM "..cacheId)
   conn:close()
   return R
end

function Cache.getAllKeys(key)
   local conn = connCreate()
   local R  = conn:query ("SELECT Ckey FROM "..cacheId..' WHERE CKey like ' .. conn:quote(tostring(key)..'%'))
   conn:close()
   return R
end

function Cache.getCount(key)
   local conn = connCreate()
   local R 
   if isNilOrEmpty(key) then
      R = conn:query ("SELECT count(*) FROM "..cacheId)
   else   
      R = conn:query ("SELECT count(*) FROM "..cacheId..' WHERE CKey like ' .. conn:quote(tostring(Key)..'%'))
   end
   conn:close()
   return R
end

-- This function resets the state of the entity table by first deleting it and then
-- recreating it.
function Cache.resetTableState()
   -- Constants.
   local DROP_TABLE_COMMAND = "DROP TABLE IF EXISTS "..cacheId
   local CREATE_TABLE_COMMAND = [[
   CREATE TABLE ]]..cacheId..[[(
   CKey Text(255) NOT NULL PRIMARY KEY,
   CValue Text(255) )
   ]]
   -- This operation is performed as a database transaction to prevent another
   -- Translator script from accidentally attempting to access the entity table
   -- while it has been temporarily deleted.
   local conn = connCreate()
   conn:begin()
   conn:execute{sql=DROP_TABLE_COMMAND, live=true}
   conn:execute{sql=CREATE_TABLE_COMMAND, live=true}
   conn:commit()
   conn:close()
end

function Cache.put(Key, Value)
   local conn = connCreate()
   local R = conn:query('REPLACE INTO '..cacheId..'(CKey, CValue) VALUES(' .. conn:quote(tostring(Key)) .. ',' .. conn:quote(tostring(Value)) .. ')')
   conn:close()
end

function Cache.pop(Key)
   local conn = connCreate()
   local R = conn:query('SELECT CValue from '..cacheId..' WHERE CKey = ' .. conn:quote(tostring(Key)))
   conn:query('DELETE from '..cacheId..' WHERE CKey = ' .. conn:quote(tostring(Key)))
   conn:close()

   if #R == 0 then
      return nil
   end

   return R[1].CValue:nodeValue()
end

function Cache.remove(Key)
   local conn = connCreate()
   conn:query('DELETE from '..cacheId..' WHERE CKey = ' .. conn:quote(tostring(Key)))
   conn:close()
end

function Cache.removeAll(Key)
   local conn = connCreate()
   if isNilOrEmpty(key) then
      conn:query('DELETE from '..cacheId)
   else   
      conn:query('DELETE from '..cacheId..' WHERE CKey like ' .. conn:quote(tostring(Key)..'%'))
   end   
   conn:close()
end

function Cache.get(Key)
   local conn = connCreate()
   local R = conn:query('SELECT CValue from '..cacheId..' WHERE CKey = ' .. conn:quote(tostring(Key)))
   conn:close()

   if #R == 0 then
      return nil
   end

   return R[1].CValue:nodeValue()
end

-- Local Functions

-- INITITALIZE DB: This automatically ensures the SQLlite database exists and has the entity table present at script compile time.   
function Cache.init(entity)
   cacheId = entity
   Cache.resetTableState()
end

--init() -- DO NOT REMOVE: Calls init() (once only) at script compile time to perform the initialization

-- help for the functions

if help then
   ------------------------
   -- Cache.getTableState()
   ------------------------
   local h = help.example()
   h.Title = 'Cache.getTableState'
   h.Desc = 'Return the state of the entity table, by selecting all the rows.'
   h.Usage = 'Cache.getTableState()'
   h.Parameters = ''
   h.Returns = {[1]={['Desc']='All the rows from the entity table <u>result set node tree</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>
      -- check the state of the entity table, if more than 1 row then empty the entity
      if  #Cache.getTableState() > 1 then
      Cache.resetTableState()
   end
      </pre>]]}
   h.SeeAlso = ''
   help.set{input_function=Cache.getTableState, help_data=h}

   --------------------------
   -- Cache.resetTableState()
   --------------------------
   local h = help.example()
   h.Title = 'Cache.resetTableState'
   h.Desc = 'Reset the state of the entity table, by deleting and recreating the table.'
   h.Usage = 'Cache.resetTableState()'
   h.Parameters = ''
   h.Returns = 'none.'
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>
      -- reset the entity table if more than 1 row exists
      if  #Cache.getTableState() > 1 then
      Cache.resetTableState()
   end
      </pre>]]}
   h.SeeAlso = ''
   help.set{input_function=Cache.resetTableState, help_data=h}

   ------------------------
   -- Cache.put()
   ------------------------
   local h = help.example()
   h.Title = 'Cache.put'
   h.Desc = [[Insert a Value for the Key. If the Key exists then replace the value. 
   If the Key does not exist insert a new Key and Value.]]
   h.Usage = 'Cache.put(Key, Value)'
   h.Parameters = {
      [1]={['Key']={['Desc']='Unique Identifier <u>string</u>'}},
      [2]={['Value']={['Desc']='Value to entity <u>string</u>'}}
   }
   h.Returns = 'none.'
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>Cache.put('I am the Key', 'I am the Value')</pre>]]}
   h.SeeAlso = ''
   help.set{input_function=Cache.put, help_data=h}

   ------------------------
   -- Cache.get()
   ------------------------
   local h = help.example()
   h.Title = 'Cache.get'
   h.Desc = 'Retrieve the Value for the specified Key.'
   h.Usage = 'Cache.get(Key)'
   h.Parameters = {
      [1]={['Key']={['Desc']='Unique Identifier <u>string</u>'}}
   }
   h.Returns = {[1]={['Desc']='The Value of the row specified by the Key <u>string</u>'}}
   h.ParameterTable = false
   h.Examples = {[1]=[[<pre>Cache.get('I am the Key')</pre>]]}
   h.SeeAlso = ''
   help.set{input_function=Cache.get, help_data=h}
end

return Cache