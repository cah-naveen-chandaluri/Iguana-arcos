local validation =  {}

function validation.validateValueString(OrderValue,ColumnSize) --validation for data that we got from elite
    print(type(OrderValue),#OrderValue)
    print(type(OrderValue:nodeText()),#OrderValue,#OrderValue:nodeText(),type(OrderValue:nodeText()))
   if(type(OrderValue)=='userdata' and #OrderValue<=ColumnSize and #OrderValue>=0 ) then
        return true
    else
        return false
    end
end


-- Validating the order data
function validation.validationForOrderData(EliteData)    -- this function will helps in validating data

    local ValidateionStatus = false
    for i=1,#EliteData do
        if(  --if 21
            validation.validateValueString(EliteData[i].ITEM_NUM,ITEM_NUM)   --if 11
            and validation.validateValueString(EliteData[i].QTY_RECEIVED,QTY_RECEIVED)  --need to check
            and validation.validateValueString(EliteData[i].CONFIRM_DATE,CONFIRM_DATE)  --need to check
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"],VENDOR_NUM)
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"],FORM_222_NUM)
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L.ORG_CODE)"],ORG_CODES)
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L.PO_NUM)"],PO_NUM)  --need to check  -- size is 38
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"],LINE_SEQ)  --need to check -- size is 38
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"],LICENSE_TYPE)
            and validation.validateValueString(EliteData[i]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"],WHSE_CODE)
            and validation.validateValueString(EliteData[i].DEA_LICENSE,DEA_LICENSE)
            and validation.validateValueString(EliteData[1]["TRIM(PROD_841_D.ITEM.UPC)"],UPC)
            )then
            ValidateionStatus = true
            TabEliteDataCorrect[i]=EliteData[i]

        else
            ValidateionStatus = false
            print(elite_data[i])
            TabEliteDataCorrect[i]=EliteData[i]
        end --end if 21

    end  --end for
    print(TabEliteDataCorrect,TabEliteDataWrong)
    return ValidateionStatus
end  --end validationForOrderData() function





return validation
