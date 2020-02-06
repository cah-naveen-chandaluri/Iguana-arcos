local validation =  {}

function validation.validate_value_string(order_value,column_size) --validation for data that we got from elite
    print(type(order_value),#order_value)
    print(type(order_value:nodeText()),#order_value,#order_value:nodeText(),type(order_value:nodeText()))
    if(order_value == '') then
        return true
    elseif(type(order_value)=='userdata' and #order_value<=column_size and #order_value>=0) then
        return true
    else
        return false
    end
end


function validation.validate_value_string2(order_value) --validation for data that we got from elite
    if(order_value == '') then
        return true
elseif(type(order_value)=='userdata') then
    return true
else
    return false
end
end


-- Validating the order data
function validation.validationForOrderData(elite_data)    -- this function will helps in validating data

    local validateion_status = false
    for i=1,#elite_data do
        if(  --if 21
            validation.validate_value_string(elite_data[i].ITEM_NUM,ITEM_NUM)   --if 11
            and validation.validate_value_string(elite_data[i].QTY_RECEIVED,QTY_RECEIVED)  --need to check
            and validation.validate_value_string2(elite_data[i].CONFIRM_DATE)  --need to check
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.VENDOR_NUM)"],VENDOR_NUM)
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L_CE.FORM_222_NUM)"],FORM_222_NUM)
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.ORG_CODE)"],ORG_CODES)
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.PO_NUM)"],PO_NUM)  --need to check  -- size is 38
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.LINE_SEQ)"],LINE_SEQ)  --need to check -- size is 38
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.ITEM_LICENSE_CE.LICENSE_TYPE)"],LICENSE_TYPE)
            and validation.validate_value_string(elite_data[i]["TRIM(PROD_841_D.PO_L.WHSE_CODE)"],WHSE_CODE)
            and validation.validate_value_string(elite_data[i].DEA_LICENSE,DEA_LICENSE)
            and validation.validate_value_string(elite_data[1]["TRIM(PROD_841_D.ITEM.UPC)"],UPC)
            )then
            validateion_status = true
            tab_elite_data_correct[i]=elite_data[i]

        else
            validateion_status = false
            print(elite_data[i])
            tab_elite_data_wrong[i]=elite_data[i]
        end --end if 21

    end  --end for
    print(tab_elite_data_correct,tab_elite_data_wrong)
    return validateion_status
end  --end validationForOrderData() function





return validation
