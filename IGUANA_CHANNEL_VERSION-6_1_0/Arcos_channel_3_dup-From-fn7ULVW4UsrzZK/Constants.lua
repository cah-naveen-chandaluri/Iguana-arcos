local constants =  {}

function constants.eliteSize()

    OutputLogPath= "C:\\IGUANA\\ARCOS\\LogFiles\\"

SHIP_L_ID = 255  
 SHIP_ID = 38
SHIPPED_QTY  = 12 
SHIP_NUM = 10
ORD_ID = 38
ORDER_NUM =38 
FORM_222_NUM  =10
UPC=15
ITEM_NUM =30
ORD_L_ID = 2
CUST_NUM=10
DEA_LICENSE=30
ORDCUST_NUM=10
ORDSHIP_NUM=10
WHSE_CODE=30
BILLTO_NAME=40
BILLTO_ADDRESS1=40
BILLTO_ADDRESS2=40
BILLTO_CITY=20
BILLTO_PROVINCE=20
BILLTO_COUNTRY=10
BILLTO_POSTAL_CODE=10
DEF_SHIPTO_NAME=40
DEF_SHIPTO_ADDR1=40
DEF_SHIPTO_CITY=20
DEF_SHIPTO_PROV =20
DEF_SHIPTO_COUNTRY=10
DEF_SHIPTO_POST_CD=10
ORG_COD = 38
BILLTO_ADDRESS3=40
DEF_SHIPTO_ADDR2=40
DEF_SHIPTO_ADDR3=40


    ORGANIZATION_CODE="'AF','M1','CL','SE','VT','EC','MO','OX','RC','UC','JD','AO','OP','SC','PS','VI','AZ','ZG','IY','MD','AW','GB','WP','PN','HW','CR','MA','QN','BO','MP','BH','NI','UP','NT'"
end

function constants.logConstants()
   
    TIME_STAMP=os.date('%x').." "..os.date('%X').." - "
    CHANNEL_STARTED_RUNNING="******* Iguana EliteImportPOData channel Started Running *******"
    CHANNEL_STOPPED_RUNNING="^^^^^^^ Iguana EliteImportPOData channel Stopped Running ^^^^^^^"
    DB_CON_ERROR_ELITE="        Database connection failed for Elite DataBase"
    DB_CON_ERROR_ARCOS="        Database connection failed for ARCOS DataBase"
    DB_CON_ERROR_ARCOS_STG="        Database connection failed for ARCOS Stage DataBase"
    INSERT_SUCCESS="        Successfully inserted data into DataBase"
    LOG_DIR_MISS="        Log Directory does not exist"
    LOG_DIR_CREATE="        Log directory created"
    VALIDATION_FAILED="        Validation failed when validating datatypes of values in database"
    VALIDATION_SUCCESS="        Validation Success"
    DELETION_FAILED="        Data not got deleted from stg_elite_po_data table"
    EMPTY_ELITE_DATA="        No data found in elite_data"
    INSERTION_FAILED="        Insertion Failed as no data is there to insert"
    COMPARE_FAILED="        Comparision failed"
   end

return constants
