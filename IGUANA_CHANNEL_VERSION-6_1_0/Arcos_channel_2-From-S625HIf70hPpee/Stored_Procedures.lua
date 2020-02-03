local Stored_Procedures =  {}

    
function Stored_Procedures.firstProcedure()   --creting update procedure
 

  -- print(UNIQUE_TRANS_NU)
 --   print(SYSTEM_DATE)
  -- conn:execute{sql='DROP PROCEDURE IF EXISTS Update_Procedure',live=true}
 --  conn:execute{sql=[[CREATE PROCEDURE Update_Procedure( 
 --   IN UNIQUE_TRANS_NU varchar(45),
 --   IN SYSTEM_DATE timestamp,
 --     IN DEFAULT_USER varchar(255)
 --  )
 --     BEGIN
 --    update 3pl_sps_ordering.csos_order_header set CSOS_ORDER_HDR_STAT ='2', ROW_UPDATE_STP=SYSTEM_DATE, ROW_UPDATE_USER_ID=DEFAULT_USER where UNIQUE_TRANS_NUM=UNIQUE_TRANS_NU;
  --   update 3pl_sps_ordering.order_header set  ORDER_HDR_STAT_DESC='2', ROW_UPDATE_STP=SYSTEM_DATE, ROW_UPDATE_USER_ID=DEFAULT_USER where CSOS_ORDER_NUM=UNIQUE_TRANS_NU;
    
   
  --  END]],
  --    live=true
  --     } 
      
      
end

function Stored_Procedures.delProcedure()
 -- conn_Arcos_stg:execute{sql='DROP PROCEDURE IF EXISTS del_Procedure',live=true}
 -- conn_Arcos_stg:execute{sql=[[CREATE PROCEDURE del_Procedure (
  -- IN VAL char(30)
   --)
   -- BEGIN
   --delete from ArcosMDB.dbo.stg_elite_po_data;
      
   --  END]],
   --  live=true
   --  }  
end
   

function Stored_Procedures.insProcedure()
   --conn_Arcos_stg:execute{sql='DROP PROCEDURE IF EXISTS Insert1',live=true}  --procedure to insert data into csos_order_header
  -- conn_Arcos_stg:execute{sql=[[CREATE PROCEDURE Insert1( 
   --[[   IN item_num char(30),
      IN qty_received	numeric(38, 0),
      IN confirm_date datetime,
      IN vendor_num char(10),
      IN form_222_num char(10),
      IN org_code char(2),
      IN po_num numeric(38, 0),
      IN line_seq numeric(38, 0),
      IN license_type	char(1),
      IN whse_code char(12),
      IN dea_license char(30)
   )
      BEGIN
      INSERT INTO csos_order_header(item_num, qty_received, confirm_date, vendor_num,form_222_num,org_code,po_num,line_seq,license_type,whse_code,dea_license) 
  ]]--    VALUES(item_num, qty_received, confirm_date, vendor_num,form_222_num,org_code,po_num,line_seq,license_type,whse_code,dea_license);
  -- END]],
   --   live=true
    --  }
   
    
   
end
   
return Stored_Procedures