local validation =  {}

function validation.validateValueString(OrderValue,ColumnSize) --validation for data that we got from elite
   if(type(OrderValue)=='userdata' and #OrderValue<=ColumnSize and #OrderValue>=0 ) then
        return true
    else
        return false
    end
end


     
-- Validating the order data
function validation.validationForOrderData(EliteData)    -- this function will helps in validating data
    local ValidateionStatus = false
  
        if(  --if 21
            validation.validateValueString(EliteData.SHIP_L_ID,SHIP_L_ID)   --if 11
            and validation.validateValueString(EliteData.SHIP_ID,SHIP_ID)  --need to check
            and validation.validateValueString(EliteData.SHIPPED_QTY,SHIPPED_QTY)  --need to check
           -- and validation.validateValueString(EliteData.SHIP_NUM,SHIP_NUM)
            and validation.validateValueString(EliteData.SHIPPED_DATE,#EliteData.SHIPPED_DATE)
           -- and validation.validateValueString(EliteData.ORD_ID,ORD_ID)
            and validation.validateValueString(EliteData.ORDER_NUM,ORDER_NUM)  --need to check  -- size is 38
            and validation.validateValueString(EliteData.FORM_222_NUM,FORM_222_NUM)  --need to check -- size is 38
            and validation.validateValueString(EliteData.UPC,UPC)
            and validation.validateValueString(EliteData.ITEM_NUM,ITEM_NUM)
          --  and validation.validateValueString(EliteData.ORD_L_ID,ORD_L_ID)
            and validation.validateValueString(EliteData.CUST_NUM,CUST_NUM)
            and validation.validateValueString(EliteData.DEA_LICENSE,DEA_LICENSE)
            and validation.validateValueString(EliteData.ORDCUST_NUM,ORDCUST_NUM)
            and validation.validateValueString(EliteData.ORDSHIP_NUM,ORDSHIP_NUM)
            and validation.validateValueString(EliteData.WHSE_CODE,WHSE_CODE)
            and validation.validateValueString(EliteData.BILLTO_NAME,BILLTO_NAME)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS1,BILLTO_ADDRESS1)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS2,BILLTO_ADDRESS2)
            and validation.validateValueString(EliteData.BILLTO_CITY,BILLTO_CITY)
            and validation.validateValueString(EliteData.BILLTO_PROVINCE,BILLTO_PROVINCE)
            and validation.validateValueString(EliteData.BILLTO_COUNTRY,BILLTO_COUNTRY)
            and validation.validateValueString(EliteData.BILLTO_POSTAL_CODE,BILLTO_POSTAL_CODE)
            and validation.validateValueString(EliteData.DEF_SHIPTO_NAME,DEF_SHIPTO_NAME)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR1,DEF_SHIPTO_ADDR1)
            and validation.validateValueString(EliteData.DEF_SHIPTO_CITY,DEF_SHIPTO_CITY)
            and validation.validateValueString(EliteData.DEF_SHIPTO_PROV,DEF_SHIPTO_PROV)
            and validation.validateValueString(EliteData.DEF_SHIPTO_COUNTRY,DEF_SHIPTO_COUNTRY)
            and validation.validateValueString(EliteData.DEF_SHIPTO_POST_CD,DEF_SHIPTO_POST_CD)
          --  and validation.validateValueString(EliteData.ORG_CODE,ORG_CODE)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS3,BILLTO_ADDRESS3)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR2,DEF_SHIPTO_ADDR2)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR3,DEF_SHIPTO_ADDR3)
            )then
            ValidateionStatus = true
            
        return ValidateionStatus
        else
            ValidateionStatus = false
         
        return ValidateionStatus
        end --end if 21

--return ValidateionStatus
end  --end validationForOrderData() function


return validation



--[[local validation =  {}

function validation.validateValueString(OrderValue,ValueDataType,ColumnSize) --validation for data that we got from elite
   if(type(OrderValue)==ValueDataType and #OrderValue<=ColumnSize and #OrderValue>=0 ) then
        return true
    else
        return false
    end
end


     
-- Validating the order data
function validation.validationForOrderData(EliteData)    -- this function will helps in validating data
    local ValidateionStatus = false
  
        if(  --if 21
            validation.validateValueString(EliteData.SHIP_L_ID,'userdata',SHIP_L_ID)   --if 11
            and validation.validateValueString(EliteData.SHIP_ID,'userdata',SHIP_ID)  --need to check
            and validation.validateValueString(EliteData.SHIPPED_QTY,'userdata',SHIPPED_QTY)  --need to check
           -- and validation.validateValueString(EliteData[i].SHIP_NUM,'userdata',SHIP_NUM)
            and validation.validateValueString(EliteData.SHIPPED_DATE,'userdata',#EliteData.SHIPPED_DATE)
           -- and validation.validateValueString(EliteData[i].ORD_ID,'userdata',ORD_ID)
            and validation.validateValueString(EliteData.ORDER_NUM,'userdata',ORDER_NUM)  --need to check  -- size is 38
            and validation.validateValueString(EliteData.FORM_222_NUM,'userdata',FORM_222_NUM)  --need to check -- size is 38
            and validation.validateValueString(EliteData.UPC,'userdata',UPC)
            and validation.validateValueString(EliteData.ITEM_NUM,'userdata',ITEM_NUM)
          --  and validation.validateValueString(EliteData[i].ORD_L_ID,'userdata',ORD_L_ID)
            and validation.validateValueString(EliteData.CUST_NUM,'userdata',CUST_NUM)
            and validation.validateValueString(EliteData.DEA_LICENSE,'userdata',DEA_LICENSE)
            and validation.validateValueString(EliteData.ORDCUST_NUM,'userdata',ORDCUST_NUM)
            and validation.validateValueString(EliteData.ORDSHIP_NUM,'userdata',ORDSHIP_NUM)
            and validation.validateValueString(EliteData.WHSE_CODE,'userdata',WHSE_CODE)
            and validation.validateValueString(EliteData.BILLTO_NAME,'userdata',BILLTO_NAME)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS1,'userdata',BILLTO_ADDRESS1)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS2,'userdata',BILLTO_ADDRESS2)
            and validation.validateValueString(EliteData.BILLTO_CITY,'userdata',BILLTO_CITY)
            and validation.validateValueString(EliteData.BILLTO_PROVINCE,'userdata',BILLTO_PROVINCE)
            and validation.validateValueString(EliteData.BILLTO_COUNTRY,'userdata',BILLTO_COUNTRY)
            and validation.validateValueString(EliteData.BILLTO_POSTAL_CODE,'userdata',BILLTO_POSTAL_CODE)
            and validation.validateValueString(EliteData.DEF_SHIPTO_NAME,'userdata',DEF_SHIPTO_NAME)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR1,'userdata',DEF_SHIPTO_ADDR1)
            and validation.validateValueString(EliteData.DEF_SHIPTO_CITY,'userdata',DEF_SHIPTO_CITY)
            and validation.validateValueString(EliteData.DEF_SHIPTO_PROV,'userdata',DEF_SHIPTO_PROV)
            and validation.validateValueString(EliteData.DEF_SHIPTO_COUNTRY,'userdata',DEF_SHIPTO_COUNTRY)
            and validation.validateValueString(EliteData.DEF_SHIPTO_POST_CD,'userdata',DEF_SHIPTO_POST_CD)
          --  and validation.validateValueString(EliteData[i].ORG_CODE,'userdata',ORG_CODE)
            and validation.validateValueString(EliteData.BILLTO_ADDRESS3,'userdata',BILLTO_ADDRESS3)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR2,'userdata',DEF_SHIPTO_ADDR2)
            and validation.validateValueString(EliteData.DEF_SHIPTO_ADDR3,'userdata',DEF_SHIPTO_ADDR3)
            )then
            ValidateionStatus = true
            
        return ValidateionStatus
        else
            ValidateionStatus = false
         
        return ValidateionStatus
        end --end if 21

--return ValidateionStatus
end  --end validationForOrderData() function


return validation

]]--
--[[
print(TabEliteDataCorrect,TabEliteDataWrong)
   print(TabEliteDataCorrect,TabEliteDataCorrect[1].SHIP_L_ID,TabEliteDataCorrect[1].SHIP_ID,TabEliteDataCorrect[1].SHIPPED_QTY)
   print(TabEliteDataCorrect[1].SHIP_NUM,TabEliteDataCorrect[1].SHIPPED_DATE,TabEliteDataCorrect[1].ORD_ID,TabEliteDataCorrect[1].ORDER_NUM)
   print(TabEliteDataCorrect[1].FORM_222_NUM,TabEliteDataCorrect[1].UPC,TabEliteDataCorrect[1].ITEM_NUM)
   print(TabEliteDataCorrect[1].ORD_L_ID,TabEliteDataCorrect[1].CUST_NUM,TabEliteDataCorrect[1].DEA_LICENSE)
   print(TabEliteDataCorrect[1].ORDCUST_NUM,TabEliteDataCorrect[1].ORDSHIP_NUM,TabEliteDataCorrect[1].WHSE_CODE)
   print(TabEliteDataCorrect[1].BILLTO_NAME,TabEliteDataCorrect[1].BILLTO_ADDRESS1,TabEliteDataCorrect[1].BILLTO_ADDRESS2)
   
   print(TabEliteDataCorrect[1].BILLTO_CITY,TabEliteDataCorrect[1].DEF_SHIPTO_COUNTRY,TabEliteDataCorrect[1].DEF_SHIPTO_POST_CD)
   print(TabEliteDataCorrect[1].ORG_CODE,TabEliteDataCorrect[1].BILLTO_ADDRESS3,TabEliteDataCorrect[1].DEF_SHIPTO_ADDR2)
   print(TabEliteDataCorrect[1].DEF_SHIPTO_ADDR3,TabEliteDataCorrect[1].BILLTO_PROVINCE,TabEliteDataCorrect[1].BILLTO_COUNTRY)
   print(TabEliteDataCorrect[1].BILLTO_POSTAL_CODE,TabEliteDataCorrect[1].DEF_SHIPTO_NAME,TabEliteDataCorrect[1].DEF_SHIPTO_ADDR1)
   print(TabEliteDataCorrect[1].DEF_SHIPTO_CITY,TabEliteDataCorrect[1].DEF_SHIPTO_COUNTRY)



print(EliteData[1].SHIP_L_ID,EliteData[1].SHIP_ID,EliteData[1].SHIPPED_QTY,EliteData[1].SHIP_NUM,EliteData[1].SHIPPED_DATE,EliteData[1].ORD_ID)
            print(EliteData[1].ORDER_NUM,EliteData[1].FORM_222_NUM,EliteData[1].UPC,EliteData[1].ITEM_NUM,EliteData[1].ORD_L_ID)

            print(EliteData[1].CUST_NUM,EliteData[1].DEA_LICENSE,EliteData[1].ORDCUST_NUM,EliteData[1].ORDSHIP_NUM)
            print(EliteData[1].WHSE_CODE,EliteData[1].BILLTO_NAME,EliteData[1].BILLTO_ADDRESS1,EliteData[1].BILLTO_ADDRESS2)
            print(EliteData[1].BILLTO_CITY,EliteData[1].BILLTO_PROVINCE,EliteData[1].BILLTO_COUNTRY,EliteData[1].BILLTO_POSTAL_CODE)

      
 print(EliteData[1].DEF_SHIPTO_NAME,EliteData[1].DEF_SHIPTO_ADDR1,EliteData[1].DEF_SHIPTO_CITY,EliteData[1]:child("DEF_SHIPTO_CITY", 2))
            print(EliteData[1].DEF_SHIPTO_COUNTRY,EliteData[1].DEF_SHIPTO_POST_CD,EliteData[1].ORG_CODE,EliteData[1].BILLTO_ADDRESS3)
            print(EliteData[1].DEF_SHIPTO_ADDR2,EliteData[1].DEF_SHIPTO_ADDR3)
]]--

