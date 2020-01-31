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
   
   
   
return Stored_Procedures