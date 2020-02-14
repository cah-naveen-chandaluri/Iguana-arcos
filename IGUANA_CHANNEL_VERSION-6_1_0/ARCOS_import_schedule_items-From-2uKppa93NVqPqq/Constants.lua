local Constants =  {}

function Constants.csos_order_header_size()


-- The main function is the first function called from Iguana.
output_log_path= "C:\\IGUANA\\ARCOS\\LogFiles\\"
TIME_STAMP=os.date('%x').." "..os.date('%X').." - "
CHANNEL_STARTED_RUNNING="******* Iguana Import_Schedule_Items channel Started Running *******"
CHANNEL_STOPPED_RUNNING="^^^^^^^ Iguana Import_Schedule_Items channel Stopped Running ^^^^^^^"  
DB_CON_ERROR_ELITE="        Database connection failed for Elite DataBase"
DB_CON_ERROR_ARCOS="        Database connection failed for ARCOS DataBase"
DB_CON_ERROR_ARCOS_STG="        Database connection failed for ARCOS Stage DataBase "
INSERT_SUCCESS="        Successfully inserted data into DataBase"
LOG_DIR_MISS="        Log Directory does not exist"
LOG_DIR_CREATE="        Log directory created"    
   sql_query=[[SELECT DISTINCT prod_841_D.Item.ITEM_NUM, prod_841_D.Item_CE.IS_LICENSE_REQ AS Lic_reqd,
          prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST, 
          prod_841_D.Item_LICENSE_CE.LICENSE_TYPE,
          prod_841_D.Item_2.BACCS, prod_841_D.Item_2.BREAK_CODE,
          prod_841_D.Item_2.USE_BREAK_CODE, prod_841_D.Item.UPC, prod_841_D.Item.DESC_1, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'I','Y','N') AS Sched1, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'II','Y','N') AS Sched2, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'III','Y','N') AS Sched3, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'IV','Y','N') AS Sched4, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'V','Y','N') AS Sched5, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'VI','Y','N') AS Sched6, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'VII','Y','N') AS Sched7, 
          decode(trim(prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST),'VIII','Y','N') AS Sched8, 
          ' ' AS contr_subst 
          FROM ((prod_841_D.Item INNER JOIN prod_841_D.Item_CE ON prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM) 
          INNER JOIN prod_841_D.Item_LICENSE_CE ON prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM) 
          INNER JOIN prod_841_D.Item_2 ON prod_841_D.Item.ITEM_NUM = prod_841_D.Item_2.ITEM_NUM
          WHERE (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='I' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                OR 
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='II' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='IIN' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='III' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                 OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='IIIN' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                 OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='IV' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                 OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST='V' )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                 OR
                (
                        ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_CE.ITEM_NUM ) And ( prod_841_D.Item.ITEM_NUM = prod_841_D.Item_LICENSE_CE.ITEM_NUM )  
                        AND ( prod_841_D.Item_LICENSE_CE.DEA_SCHEDULE_LIST is null )   AND ( prod_841_D.Item_2.ITEM_NUM=prod_841_D.Item.ITEM_NUM )
                )
                and
            
            ( prod_841_D.Item.DESC_1 not Like '%DO NOT USE%' and prod_841_D.Item.DESC_1 not Like 'DISPOSAL%' )
      
            ]]
 
end

function Constants.eliteSize()
Validation.validateValueString(ItemDataFromElite[i].item_num,30)   --if 11
            and Validation.validateValueString(ItemDataFromElite[i].lic_reqd,1)  --need to check
            and Validation.validateValueString(ItemDataFromElite[i].sched1,1)  --need to check
            and Validation.validateValueString(ItemDataFromElite[i].sched2,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched3,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched4,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched5,1)  --need to check  -- size is 38
            and Validation.validateValueString(ItemDataFromElite[i].sched6,1)  --need to check -- size is 38
            and Validation.validateValueString(ItemDataFromElite[i].sched7,1)
            and Validation.validateValueString(ItemDataFromElite[i].sched8,1)
            and Validation.validateValueString(ItemDataFromElite[i].baccs,1)
            and Validation.validateValueString(ItemDataFromElite[i].break_code,4)
            and Validation.validateValueString(ItemDataFromElite[i].use_break_code,1)
            and Validation.validateValueString(ItemDataFromElite[i].upc,15)
            and Validation.validateValueString(ItemDataFromElite[i].desc_1,70)
end

return Constants