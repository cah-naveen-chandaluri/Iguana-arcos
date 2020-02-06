local constants =  {}

function constants.elite_size()

    output_log_path= "C:\\IGUANA\\ARCOS\\LogFiles\\"

    ITEM_NUM=50
    QTY_RECEIVED=38
    VENDOR_NUM=50
    FORM_222_NUM=50
    ORG_CODES=2
    PO_NUM=38
    LINE_SEQ=38
    LICENSE_TYPE=1
    WHSE_CODE=50
    DEA_LICENSE=50
    UPC=50

    ORG_CODE="'SB','AF','M1','CL','SE','VT','EC','MO','OX','RC','UC','JD','AO','OP','SC','PS','VI','AZ','ZG','IY','MD','AW','GB','WP','PN','HW','CR','MA','QN','BO','MP','BH','NI','UP','NT'"
    
end

function constants.log_Constants()
   
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
   
   end

return constants
