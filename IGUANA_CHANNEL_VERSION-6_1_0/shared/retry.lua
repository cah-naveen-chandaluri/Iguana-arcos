-- $Revision: 1.7 $
-- $Date: 2014-03-10 09:22:33 $

--
-- The retry module
-- Copyright (c) 2011-2014 iNTERFACEWARE Inc. ALL RIGHTS RESERVED
-- iNTERFACEWARE permits you to use, modify, and distribute this file in accordance
-- with the terms of the iNTERFACEWARE license agreement accompanying the software
-- in which it is used.
--

-- customize the (generic) error messages used by retry() if desired

-- Customized to integrate with Tecsys libraries on 2015-07-28 by timk

local RETRIES_FAILED_MESSAGE = 'Retries completed - was unable to recover from connection error.'
local FATAL_ERROR_MESSAGE    = 'Stopping channel - fatal error, function returned false. Function name: '
local RECOVERED_MESSAGE      = 'Recovered from error, connection is now working. Function name: '

-- 3Hr = 1080 times 10 sec = 10800 sec
local DEF_RETRY = 1080
local DEF_PAUSE = 10
RETRY_TIMEOUT = DEF_RETRY * DEF_PAUSE

local retry={}

local function sleep(S)
   if not iguana.isTest() then
      util.sleep(S*1000)
   end
end

-- hard-coded to allow "argN" params (e.g., arg1, arg2,...argN)
local function checkParam(T, List, Usage)
   if type(T) ~= 'table' then
      error(Usage,3)
   end
   for k,v in pairs(List) do
      for w,x in pairs(T) do
         if w:find('arg') then
            if w == 'arg' then error('Unknown parameter "'..w..'"', 3) end
         else
            if not List[w] then error('Unknown parameter "'..w..'"', 3) end
         end
      end
   end
end

-- hard-coded for "argN" params (e.g., arg1, arg2,...argN)
local function getArgs(P)
   local args = {}
   for k,v in pairs(P) do
      if k:find('arg')==1 then
         args[tonumber(k:sub(4))] = P[k]
      end
   end
   return args
end

-- This function will call with a retry sequence - default is 100 times with a pause of 10 seconds between retries
function retry.call(P)--F, A, RetryCount, Delay)
   checkParam(P, {func=0, retry=0, pause=0, funcname=0, errorfunc=0}, Usage)
   if type(P.func) ~= 'function' then
      error('The "func" argument is not a function type, or it is missing (nil).', 2)
   end 
    
   stackTrace ={}
   local RetryCount = P.retry or DEF_RETRY
   local Delay = P.pause or DEF_PAUSE
   local Fname = P.funcname or 'not specified'
   local Func = P.func
   local ErrorFunc = P.errorfunc
   local Info = 'Will retry '..RetryCount..' times with pause of '..Delay..' seconds.'
   local Success, ErrMsgOrReturnCode, IsFatal
   local Args = getArgs(P)

   trace(Fname)   
   
   if iguana.isTest() then 
      RetryCount = 2
      errorIndex = 2
   end
   
   for i =1, RetryCount do
      
      -- Execute the function with given argument(s)
      local R = {pcall(Func, unpack(Args))}
      
      trace(R)
      Success = R[1]
      ErrMsgOrReturnCode = R[2]
      trace(ErrMsgOrReturnCode)

      -- Execute custom error handler, which could change the value of Success variable based on custom logic
      if not Success and ErrorFunc then
         Success, IsFatal = ErrorFunc(unpack(R))
      end
      
      if Success or IsFatal then
         -- Function call did not throw an error 
         -- but we still have to check for function returning false
         
         if IsFatal then
            error(FATAL_ERROR_MESSAGE..Fname..'()')
         end
         
         if (i > 1) then
            iguana.setChannelStatus{color='green', text=RECOVERED_MESSAGE..Fname..'()'}
            iguana.logInfo(RECOVERED_MESSAGE..Fname..'()')
         end
         -- add Info message as the last of (potentially) multiple returns
         R[#R+1] = Info; trace(R)
         return unpack(R,2)
         
      else
         if iguana.isTest() then 
            -- TEST ONLY: add Info message as the last of (potentially) multiple returns
            R[#R+1] = Info
            return "SIMULATING RETRY: "..tostring(unpack(R,2)) -- test return "PRETENDING TO RETRY"
         else -- LIVE
            -- keep retrying if Success ~= true
            local E = 'Error executing operation. Retrying ('..i..' of '..RetryCount..')'
            iguana.setChannelStatus{color='yellow', text=E}
            sleep(Delay)
            iguana.logInfo(E)
         end 
      end
   end
   
   -- stop channel if retries are unsuccessful
   iguana.setChannelStatus{text=RETRIES_FAILED_MESSAGE}
   error(RETRIES_FAILED_MESSAGE..' Function: '..Fname..'(). Stopping channel.\n'..tostring(ErrMsgOrReturnCode.message)) 
end

local retryHelp={
   SummaryLine = 'Retries a function, using the specified retries and pause time.',
   Desc =[[Retries a function, using the specified number of retries and pause time in seconds.
   <p>
   The purpose is to implement retry logic in interfaces that handle resources which may not always be available, e.g., databases, webservices etc. 
   If the function throws an error this module logs an informational message containing the error details, then it sleeps and then retries the operation after the specified "pause" time (in seconds). 
   <p>
   By default if the function returns <b>false</b> it is treated as a "fatal" error and the error will be re-thrown which will (usually) stop the channel.<br>
   <b>Note</b>: You can also customize error handling by using the <b>errorfunc</b> parameter to supply a custom error handling function.
   <p>
   Any number of functions arguments are supported, in the form: arg1, arg2,... argN.]],        
   Usage = "retry.call{'func'=&lt;value&gt; [, 'arg1, arg2,... argN'=&lt;value&gt;] [, retry=&lt;value&gt;] [, pause=&lt;value&gt;] [, funcname=&lt;value&gt;]} [, errorfunc=&lt;value&gt;]}",
   ParameterTable=true,
   Parameters ={ {func={Desc='The function to call <u>function</u>'}}, 
                 {['arg1, arg2,... argN']={Desc='One or more arguments to the function, in the form: arg1, arg2,... argN <u>any type</u>', Opt=true}},
                 {retry={Desc='Count of times to retry (default = 100) <u>integer</u>', Opt=true}},
                 {pause={Desc='Delay between retries in seconds (default = 10) <u>integer</u>', Opt=true}},
                 {funcname={Desc='Name of the function (informational only for errors and logging) <u>string</u>', Opt=true}},
                 {errorfunc={Desc='A custom error handling function <u>function</u>', Opt=true}},
   },
   Returns ={ {Desc='<b>Multiple Returns</b>: Zero or more returns from the function call OR a single ERROR return when an error occurs <u>any type</u>'}, 
              {Desc=[[<b>Last Return</b>: Informational message describing the retry count and pause delay <u>string</u>
                      <p><b>Note</b>: If nothing is returned from the function then the informational message becomes the first (and only) return]]},
   },
   Title = 'retry.call',  
   SeeAlso = { {Title='Module reference for the retry.lua module', Link='http://help.interfaceware.com/kb/1487'},
               {Title='Handling retries for unreliable external resources', Link='http://help.interfaceware.com/kb/482'}},
   Examples={'local R, M = retry.call{func=DoInsert, retry=1000, pause=10}',
             [[local R, M = retry.call{func=Hello, arg1={'Hello', 'World',}, retry=99, pause=3, funcname='Hello'}]],
             [[local R, M = retry.call{func=Hello, arg1='Hello', arg2='World', retry=99, pause=3,funcname='Hello'}
             <br>-- the order of arguments within the table is not important - so this will also work]]..
             [[<br>local R, M = retry.call{func=Hello, arg3='(again)', arg2='World', retry=99, pause=3,funcname='Hello', arg1='Hello'}]],
             [[-- where "myErrorFunc" is a function created specifically for customized error handling]]..
             [[<br>local R, R2, M = retry.call{func=DoInsert, retry=1000, pause=10, funcname='DoInsert', arg1=10, errorfunc=myErrorFunc}]],
   }
}

help.set{input_function=retry.call,help_data=retryHelp}

return retry