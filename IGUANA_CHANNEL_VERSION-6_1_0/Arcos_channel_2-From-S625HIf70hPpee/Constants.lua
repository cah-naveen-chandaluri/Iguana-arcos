local Constants =  {}

function Constants.csos_order_header_size()


-- The main function is the first function called from Iguana.
output_log_path= "C:\\ARCOS\\LogFiles\\"
TIME_STAMP=os.date('%x').." "..os.date('%X').." - "
CHANNEL_STARTED_RUNNING="******* Iguana Import_Schedule_Items channel Started Running *******"
CHANNEL_STOPPED_RUNNING="^^^^^^^ Iguana Import_Schedule_Items channel Stopped Running ^^^^^^^"  
DB_CON_ERROR_ELITE="        Database connection failed for Elite DataBase"
DB_CON_ERROR_ARCOS="        Database connection failed for ARCOS DataBase"
DB_CON_ERROR_ARCOS_STG="        Database connection failed for ARCOS Stage DataBase"
INSERT_SUCCESS="        Successfully inserted data into DataBase"
LOG_DIR_MISS="        Log Directory does not exist"
LOG_DIR_CREATE="        Log directory created" 
   VALIDATION_FAILED="        Validation failed when validating datatypes of values in database"
   VALIDATION_SUCCESS="        Validation Success"
   ITEM_NUM=30
   QTY_RECEIVED=2147483647
   VENDOR_NUM=10
   FORM_222_NUM=10
   ORG_CODES=2
   PO_NUM=38
   LINE_SEQ=38
   LICENSE_TYPE=1
   WHSE_CODE=12
   DEA_LICENSE=30
   -- In this way we can pass complete table values as a string
   
ORG_CODE="'SB','AF','M1','CL','SE','VT','EC','MO','OX','RC','UC','JD','AO','OP','SC','PS','VI','AZ','ZG','IY','MD','AW','GB','WP','PN','HW','CR','MA','QN','BO','MP','BH','NI','UP','NT'"


   
   sql_query=[[
select PROD_841_D.PO_L.ITEM_NUM, (PROD_841_D.PO_L.qty_ordered-PROD_841_D.PO_L.qty_to_receive) AS qty_received, 
PROD_841_D.PO_L.LAST_RECEIPT AS CONFIRM_DATE, PROD_841_D.PO_L.VENDOR_NUM, PROD_841_D.PO_L_CE.FORM_222_NUM, 
PROD_841_D.PO_L.ORG_CODE, PROD_841_D.PO_L.PO_NUM, PROD_841_D.PO_L.LINE_SEQ, 
PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE, 
PROD_841_D.PO_L.WHSE_CODE,
PROD_841_D.LICENSE_CE.LICENSE_NUM AS DEA_License 
from PROD_841_D.PO_L inner join PROD_841_D.PO_L_CE
on ((PROD_841_D.PO_L.ORG_CODE = PROD_841_D.PO_L_CE.ORG_CODE) AND 
(PROD_841_D.PO_L.PO_NUM = PROD_841_D.PO_L_CE.PO_NUM) AND 
(PROD_841_D.PO_L.LINE_SEQ = PROD_841_D.PO_L_CE.LINE_SEQ) ) 
inner join PROD_841_D.ITEM_LICENSE_CE on PROD_841_D.PO_L.ITEM_NUM = PROD_841_D.ITEM_LICENSE_CE.ITEM_NUM
INNER JOIN PROD_841_D.LICENSE_XREF_CE ON PROD_841_D.PO_L.VENDOR_NUM = PROD_841_D.LICENSE_XREF_CE.VENDOR_NUM
INNER JOIN PROD_841_D.LICENSE_CE ON PROD_841_D.LICENSE_XREF_CE.LICENSE_ID = PROD_841_D.LICENSE_CE.LICENSE_ID 
 WHERE (
(PROD_841_D.PO_L.LAST_RECEIPT) >=  sysdate - 1260)
AND (PROD_841_D.PO_L.ORG_CODE in (]]..ORG_CODE..[[))

AND (PROD_841_D.LICENSE_CE.LICENSE_TYPE =2)
AND ((PROD_841_D.LICENSE_CE.LICENSE_NUM) != 'EXEMPT' And (PROD_841_D.LICENSE_CE.LICENSE_NUM) != '00002868-MWD' And (PROD_841_D.LICENSE_CE.LICENSE_NUM) != '1000585')   
  
   ]]
end

return Constants