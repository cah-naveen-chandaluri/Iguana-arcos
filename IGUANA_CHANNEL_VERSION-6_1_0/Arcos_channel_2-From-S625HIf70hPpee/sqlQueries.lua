local sqlQueries =  {}

function sqlQueries.queries()     --function is to call queries

SqlSelElite=[[                            
select distinct
CASE WHEN PROD_841_D.PO_L.ITEM_NUM LIKE 'CF%' THEN substr(TRIM(PROD_841_D.PO_L.ITEM_NUM), 3)
	 ELSE TRIM(PROD_841_D.PO_L.ITEM_NUM) END
	 AS ITEM_NUM,
TRIM((PROD_841_D.PO_L.qty_ordered-PROD_841_D.PO_L.qty_to_receive)) AS qty_received, 
TRIM(PROD_841_D.PO_L.LAST_RECEIPT) AS CONFIRM_DATE,
TRIM(PROD_841_D.PO_L.VENDOR_NUM),
TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM), 
TRIM(PROD_841_D.PO_L.ORG_CODE),
TRIM(PROD_841_D.PO_L.PO_NUM),
TRIM(PROD_841_D.PO_L.LINE_SEQ), 
TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE), 
TRIM(PROD_841_D.PO_L.WHSE_CODE),
TRIM(PROD_841_D.LICENSE_CE.LICENSE_NUM) AS DEA_License,
TRIM(prod_841_D.Item.upc) 
from PROD_841_D.PO_L inner join PROD_841_D.PO_L_CE
on ((PROD_841_D.PO_L.ORG_CODE = PROD_841_D.PO_L_CE.ORG_CODE) AND 
(PROD_841_D.PO_L.PO_NUM = PROD_841_D.PO_L_CE.PO_NUM) AND 
(PROD_841_D.PO_L.LINE_SEQ = PROD_841_D.PO_L_CE.LINE_SEQ) ) 
inner join PROD_841_D.ITEM_LICENSE_CE on PROD_841_D.PO_L.ITEM_NUM = PROD_841_D.ITEM_LICENSE_CE.ITEM_NUM
INNER JOIN PROD_841_D.LICENSE_XREF_CE ON PROD_841_D.PO_L.VENDOR_NUM = PROD_841_D.LICENSE_XREF_CE.VENDOR_NUM
INNER JOIN PROD_841_D.LICENSE_CE ON PROD_841_D.LICENSE_XREF_CE.LICENSE_ID = PROD_841_D.LICENSE_CE.LICENSE_ID
INNER JOIN prod_841_D.Item ON prod_841_D.Item.ITEM_NUM = PROD_841_D.PO_L.ITEM_NUM
WHERE (
(PROD_841_D.PO_L.LAST_RECEIPT) >=  sysdate - 1400) -- Duration should be 30 days in stage and production.
AND (PROD_841_D.PO_L.ORG_CODE in (]]..ORG_CODE..[[))
AND (PROD_841_D.LICENSE_CE.LICENSE_TYPE =2)
AND ((PROD_841_D.LICENSE_CE.LICENSE_NUM) != 'EXEMPT' And (PROD_841_D.LICENSE_CE.LICENSE_NUM) != '00002868-MWD' And (PROD_841_D.LICENSE_CE.LICENSE_NUM) != '1000585')

   ]]    --query for reading data from elite
   
    
   SqlDeleteStgElitePoData="delete from ArcosMDB.dbo.stg_elite_po_data"   --query for deleting data from stg_elite_po_data table
   SqlSelStgElitePoData="select * from ArcosMDB.dbo.stg_elite_po_data"     --query for checking status by selecting 
   SqlCompDelStgElitePoData="DELETE s FROM ArcosMDB.dbo.stg_elite_po_data s inner join ArcosMDB.dbo.trnsctn t on s.item_num = t.item_id WHERE  s.vendor_num = t.cust_id AND  s.po_num= t.ship_po_num AND  s.line_seq= t.ship_po_line_num"   -- query is for comparing stg_elite_po_data table and trnsctn table 
   SqlInsTrnsctn=[[INSERT INTO ArcosMDB.dbo.trnsctn (item_id, quantity, trnsctn_date, cust_id, order_form_id, assoc_registrant_dea, trnsctn_cde, row_add_stp, row_add_user_id, cord_dea, order_num, ship_po_num, ship_po_line_num, unit, whse, upc)
                     Select item_num,qty_received,confirm_date,vendor_num,form_222_num,dea_license,'P',Getdate(),'Iquana User -' + convert(varchar(100), Getdate()),CASE WHEN whse_code = 'CORD100' THEN 'RC0229965' ELSE 'RC0361206' END  AS CordDEA,po_num,po_num,line_seq,'',whse_code,upc
                     from  ArcosMDB.dbo.stg_elite_po_data
                     WHERE (form_222_num  not like  '3PL*'  OR  form_222_num  Is  Null)]]   --query for inserting data into trnsctn table
end




function sqlQueries.beforeInsertion(elite_data,tab_elite_data_correct,i)
 
      sql_ins_stg_elite_po_data =
            [[
                    INSERT INTO ArcosMDB.dbo.stg_elite_po_data(item_num,
                    qty_received,
                    confirm_date,
                    vendor_num,
                    form_222_num,
                    org_code,
                    po_num,
                    line_seq,
                    license_type,
                    whse_code,
                    dea_license,
                    upc
                  )
                    VALUES
                  (
                  ]]..
            "'"..TabEliteDataCorrect[i].ITEM_NUM.."',"..
            "\n   '"..TabEliteDataCorrect[i].QTY_RECEIVED.."',"..
            "\n   '"..TabEliteDataCorrect[i].CONFIRM_DATE.."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L.ORG_CODE)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L.PO_NUM)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"].."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"].."',"..
            "\n   '"..TabEliteDataCorrect[i].DEA_LICENSE.."',"..
            "\n   '"..TabEliteDataCorrect[i]["TRIM(PROD_841_D.ITEM.UPC)"].."'"..

            '\n   )'
   
return sql_ins_stg_elite_po_data
end





return sqlQueries