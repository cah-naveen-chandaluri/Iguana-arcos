-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

--Global tables
FileType = {["XML"] = 1, ["X12"] = 2, ["TAR"] = 3, ["ZIP"] = 4, ["TXT"] = 5, ["JSON"] = 6, ["Other"] = 7, 
   isValid = function(arg) 
      return type(arg) == 'string' and FileType[arg] ~= nil 
   end, 
   index = function(arg) 
      for k,v in pairs(FileType) do 
         if arg == v then 
            return k 
         end 
      end 
      return '' 
   end,
   isXml = function(arg) return arg == 1 end,
   isX12 = function(arg) return arg == 2 end,
   isTar = function(arg) return arg == 3 end,
   isZip = function(arg) return arg == 4 end,
   isTxt = function(arg) return arg == 5 end,
   isJson = function(arg) return arg == 6 end,
   isOther = function(arg) return arg == 7 end
}
Source = {["OpenText"] = 1, ["SFTP"] = 2, ["SMS"] = 3, ["DMS"] = 4, ["SPS"] = 5, ["CAFE"] = 6, ["FBO"] = 7, ["IMPRS"] = 8, ["Client"] = 9, ["Other"] = 10, 
   isValid = function(arg) return type(arg) == 'string' and Source[arg] ~= nil end, 
   index = function(arg) for k,v in pairs(Status) do if arg == v then return k end end return '' end}
Status = {["New"] = 1, ["Processing"] = 2, ["Processed"] = 3, ["ProcessedWithWarning"] = 4, ["Error"] = 5, ["NotApplicable"] = 6, 
   index = function(arg) for k,v in pairs(Status) do if arg == v then return k end end return '' end}
DocType = {[850] = '850', [852] = '852', [856] = '856', [867] = '867', [940] = '940', ["CAR"] = 'CAR', ["SAR"] = 'SAR', ["STG"] = 'STG', ["SOD"] = 'SOD', ["SOS"] = 'SOS',
   isValid = function(arg) return DocType[arg] ~= nil end}

