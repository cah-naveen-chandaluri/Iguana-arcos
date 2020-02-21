local sqlQueries =  {}

function sqlQueries.queries()     --function is to call queries
  --query for reading data from elite
   SqlSelElite=[[SELECT DISTINCT
    TRIM(shpl.ship_l_id) ship_l_id,
    TRIM(shpl.ship_id) ship_id,
    TRIM(shpl.shipped_qty) shipped_qty,
    TRIM(sh.ship_num) ship_num,
    TRIM(sh.shipped_date) shipped_date,
    TRIM(sh.ord_id) ord_id,
    TRIM(ord.order_num) order_num,
    TRIM(ordlce.form_222_num) form_222_num,
    TRIM(item.upc) upc,
        CASE
            WHEN (
                    shpl.item_num LIKE 'CF%'
                AND
                    sh.org_code = 'CF'
            ) THEN substr(
                TRIM(shpl.item_num),
                2 - length(shpl.item_num)
            )
            ELSE shpl.item_num
        END
    AS item_num,
    shpl.ord_l_id,
        CASE
            WHEN sh.ship_num IS NULL THEN TRIM(sh.cust_num)
            ELSE TRIM(sh.ship_num)
        END
    AS cust_num,
    TRIM(lce.license_num) dea_license,
    TRIM(ordl.cust_num) ordcust_num,
    TRIM(ordl.ship_num) ordship_num,
    TRIM(shpl.whse_code) whse_code,
    TRIM(ord.billto_name) billto_name,
    TRIM(ord.billto_address1) billto_address1,
    TRIM(ord.billto_address2) billto_address2,
    TRIM(ord.billto_address3) billto_address3,
    TRIM(ord.billto_city) billto_city,
    TRIM(ord.billto_province) billto_province,
    TRIM(ord.billto_country) billto_country,
    TRIM(ord.billto_postal_code) billto_postal_code,
    TRIM(ord.def_shipto_name) def_shipto_name,
    TRIM(ord.def_shipto_addr1) def_shipto_addr1,
    TRIM(ord.def_shipto_addr2) def_shipto_addr2,
    TRIM(ord.def_shipto_addr3) def_shipto_addr3,
    TRIM(ord.def_shipto_city) def_shipto_city,
    TRIM(ord.def_shipto_prov) def_shipto_prov,
    TRIM(ord.def_shipto_country) def_shipto_country,
    TRIM(ord.def_shipto_post_cd) def_shipto_post_cd,
    TRIM(sh.org_code) org_code
FROM
    prod_841_d.ship sh
    INNER JOIN prod_841_d.ship_l shpl ON
        sh.ship_id = shpl.ship_id
    AND
        shpl.ord_l_id IS NOT NULL
    INNER JOIN prod_841_d.ord_l ordl ON ordl.ord_l_id = shpl.ord_l_id
    INNER JOIN prod_841_d.ord_l_ce ordlce ON
        ordl.ord_l_id = CAST(ordlce.ord_l_id AS NUMERIC)
    AND (
            ordlce.form_222_num NOT LIKE '3PL*'
        OR
            ordlce.form_222_num IS NULL
    )
    INNER JOIN prod_841_d.ord ord ON
        CAST(ord.ord_id AS VARCHAR(100) ) = ordl.ord_id
    AND
        ord.order_date >= ( trunc(SYSDATE) - 90 )
    INNER JOIN prod_841_d.license_xref_ce xref ON
        xref.cust_num = ordl.cust_num
    AND
        xref.ship_num = ordl.ship_num
    INNER JOIN prod_841_d.customer_2 cust ON cust.cust_num = xref.cust_num
    INNER JOIN prod_841_d.license_ce lce ON
        lce.license_id = xref.license_id
    AND
        lce.license_type = 2
    AND
        lce.license_num IS NOT NULL
    INNER JOIN prod_841_d.item item ON item.item_num = shpl.item_num
WHERE
        sh.shipped_date > ( trunc(SYSDATE) - 30 )
    AND
        ord.org_code IN (]]..ORGANIZATION_CODE..[[)
   ]]
    
   SqlDeleteStgEliteSalesData="delete from ArcosMDB.dbo.stg_elite_sales_data"   --query for deleting data from stg_elite_po_data table
   SqlSelStgEliteSalesData="select * from ArcosMDB.dbo.stg_elite_sales_data"     --query for checking status by selecting 
   SqlCompDelStgEliteSalesData="DELETE s FROM ArcosMDB.dbo.stg_elite_sales_data s inner join ArcosMDB.dbo.trnsctn t on (s.ship_id = t.Ship_PO_Num and s.ship_l_id = t.ship_po_line_num)"   -- query is for comparing stg_elite_po_data table and trnsctn table 
   SqlInsTrnsctn=[[INSERT INTO ArcosMDB.dbo.trnsctn(trnsctn_cde,row_add_stp,row_add_user_id,cord_dea,item_id,quantity,cust_id,trnsctn_date, order_form_id, assoc_registrant_dea, order_num,	ship_po_line_num, ship_po_num,unit,whse,cust_nam,address1,address2,address3,city,state,zip,upc)
	SELECT 'S' AS Trans_Code, Getdate() AS DateCreated, 'Iquana User -' + convert(varchar(100), Getdate()) AS CreatedBy, 'RC0229965' AS CordDEA,item_num,shipped_qty, cust_num, shipped_date, form_222_num, dea_license, order_num, ship_l_id, ship_id, ' ' AS Unit, whse_code, def_shipto_name, def_shipto_addr1, def_shipto_addr2, def_shipto_addr3, def_shipto_city, def_shipto_prov, def_shipto_post_cd,upc
	FROM ArcosMDB.dbo.stg_elite_sales_data stg
	inner join 
	ArcosMDB.dbo.schedule_item si
	on si.item_num = stg.item_num;]]   --query for inserting data into trnsctn table
end




function sqlQueries.beforeInsertion(elite_data,i)

    sql_ins_stg_elite_po_data =
            [[
                    INSERT INTO ArcosMDB.dbo.stg_elite_sales_data
			(ship_l_id           ,ship_id           ,item_num           ,shipped_qty              ,shipped_date          
   ,order_num           ,   form_222_num           ,upc           ,cust_num           ,dea_license           ,
   ordcust_num           ,ordship_num           ,whse_code           ,billto_name           ,billto_address1           ,billto_address2
           ,billto_address3           ,billto_city
           ,billto_province ,billto_country           ,billto_postal_code           ,def_shipto_name,      def_shipto_addr1
           ,def_shipto_addr2           ,def_shipto_addr3           ,def_shipto_city,       def_shipto_prov,      def_shipto_country
           ,def_shipto_post_cd
                  )
                    VALUES
                  (
                  ]]..
            "NULLIF('"..EliteData[i].SHIP_L_ID.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].SHIP_ID.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].ITEM_NUM.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].SHIPPED_QTY.."', '')".. ","..
            --"\n   '"..EliteData[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"].."',"..
   
            "\n  NULLIF('"..EliteData[i].SHIPPED_DATE.."', '')".. ","..--this is the change we need to make
   
            "\n   NULLIF('"..EliteData[i].ORDER_NUM.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].FORM_222_NUM.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].UPC.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].CUST_NUM.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].DEA_LICENSE.."', '')".. ","..
            "\n   NULLIF('"..EliteData[i].ORDCUST_NUM.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].ORDSHIP_NUM.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].WHSE_CODE.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_NAME.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_ADDRESS1.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_ADDRESS2.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_ADDRESS3.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_CITY.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_PROVINCE.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_COUNTRY.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].BILLTO_POSTAL_CODE.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_NAME.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_ADDR1.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_ADDR2.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_ADDR3.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_CITY.."', '')".. ","..
    "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_PROV.."', '')".. ","..
   "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_COUNTRY.."', '')".. ","..
   
            "\n   NULLIF('"..EliteData[i].DEF_SHIPTO_POST_CD.."', '')".. 

            '\n   )'
   
return sql_ins_stg_elite_po_data   
     
end


return sqlQueries