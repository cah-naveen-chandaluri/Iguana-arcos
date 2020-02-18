local DatabaseConnection =  {}

function DatabaseConnection.connectdb()
 
   -- Database Connection Arcos - Dev  
   if not ArcosDBConn or ArcosDBConn:check() then
      if ArcosDBConn and ArcosDBConn:check() then
         ArcosDBConn:close() end
         ArcosDBConn = db.connect{   
         api=db.SQL_SERVER, 
         name='cah_arcos_dev',
         user='ARCOSIguana',
         password='ARCOS#%$@21Ig',
         use_unicode = true,
         live = true
      }
   end
        
   -- Database Connection Elite - Dev 
   if not EliteDBConn or EliteDBConn:check() then
      if EliteDBConn and EliteDBConn:check() then
         EliteDBConn:close() end
         EliteDBConn = db.connect{
         api=db.ORACLE_OCI,
         name='//ldec0409val2d01.cardinalhealth.net:1521/val2d/',
         user='sps_service',
         password='mickey222',
         use_unicode = true,
         live = true
      }
   end

end



return DatabaseConnection