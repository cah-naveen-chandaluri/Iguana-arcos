local DatabaseConnection =  {}

function DatabaseConnection.connectdb()
 
   -- Database Connection Arcos - STAGE  
   if not conn_arcos_stg or conn_arcos_stg:check() then
      if conn_arcos_stg and conn_arcos_stg:check() then
         conn_arcos_stg:close() end
      conn_arcos_stg = db.connect{   
         api=db.SQL_SERVER, 
         name='SQLDRIVER',
         user='ARCOSIguana',
         password='ARCOS#%$@21Ig',
         use_unicode = true,
         live = true
      }
   end
        
   -- Database Connection Elite - DEV  
   if not conn_elite_dev or conn_elite_dev:check() then
      if conn_elite_dev and conn_elite_dev:check() then
         conn_elite_dev:close() end
      conn_elite_dev = db.connect{
         api=db.ORACLE_OCI,
         name='//lsec0409val1s01.cardinalhealth.net:1521/val1s/',
         user='sps_service',
         password='mickey222',
         use_unicode = true,
         live = true
      }
   end

end
return DatabaseConnection