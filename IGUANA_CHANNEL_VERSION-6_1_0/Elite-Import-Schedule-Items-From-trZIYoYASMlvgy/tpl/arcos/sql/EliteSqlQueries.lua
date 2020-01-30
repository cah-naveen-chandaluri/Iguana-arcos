local EliteSqlQueries = {}

function EliteSqlQueries.export_schedule_item()
   
exportScheduleItemsFromElite = [[SELECT DISTINCT prod_841_D.Item.ITEM_NUM, decode(prod_841_D.Item_CE.IS_LICENSE_REQ,1,'Y','N') AS Lic_reqd, 
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
return EliteSqlQueries