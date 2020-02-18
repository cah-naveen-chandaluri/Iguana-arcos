-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

local EliteStageLoadFromStaging = {}
local this = {}

EliteStageLoadFromStaging.Customer = [[MERGE  [dbo].[Customer] AS customer  
USING (  
 SELECT DISTINCT ca.CustomerId, stgCust.org_code, stgCust.charge_to_num
FROM [dbo].[Elite_Stage_Customer] stgCust
    JOIN [dbo].[CustomerAddress] ca
    ON ca.OrganizationCode = stgCust.org_code
        AND ca.CustomerNumber = stgCust.cust_num
        AND stgCust.tag = '%s'
) AS stage  
    ON customer.OrganizationCode = stage.org_code
    AND customer.CustomerId = stage.CustomerId  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        customer.ChargeToNumber
EXCEPT
    SELECT
        stage.charge_to_num  
) THEN  
 UPDATE SET  
  customer.ChargeToNumber = stage.charge_to_num;

MERGE  [dbo].[Customer] AS customer  
USING (  
 SELECT DISTINCT
    org_code,
    charge_to_num,
    (  
   SELECT TOP 1
        x.sa_cust
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.sa_cust <> ''  
  ) AS sa_cust,
    (  
   SELECT TOP 1
        x.dea_lic
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.dea_lic <> ''  
  ) AS dea_lic,
    (  
   SELECT TOP 1
        x.dea_expiry
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.dea_expiry <> ''  
  ) AS dea_expiry,
    (  
   SELECT TOP 1
        x.sbp_lic
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.sbp_lic <> ''  
  ) AS sbp_lic,
    (  
   SELECT TOP 1
        x.sbp_expiry
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.sbp_expiry <> ''  
  ) AS sbp_expiry,
    (  
   SELECT TOP 1
        x.sbp_state
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.sbp_state <> ''  
  ) AS sbp_state,
    (  
   SELECT TOP 1
        x.terr_code
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.terr_code <> ''  
  ) AS terr_code,
    (  
   SELECT TOP 1
        x.desig_code_1
    FROM Elite_Stage_Customer x
    WHERE x.org_code = result.org_code
        AND x.charge_to_num = result.charge_to_num
        AND x.desig_code_1 <> ''  
  ) AS desig_code_1
FROM Elite_Stage_Customer result  
) AS stage  
    ON customer.OrganizationCode = stage.org_code
    AND customer.ChargeToNumber = stage.charge_to_num  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        customer.ChargeToNumber  
      , customer.SAGroup  
      , customer.DEALicenseNumber  
      , customer.DEALicenseExpiration  
      , customer.StateLicenseNumber  
      , customer.StateLicenseExpiration  
      , customer.StateLicenseState  
      , customer.TerritoryCode  
      , customer.ProfessionalDesignation
EXCEPT
    SELECT
        stage.charge_to_num  
      , stage.sa_cust  
      , stage.dea_lic  
      , stage.dea_expiry  
      , stage.sbp_lic  
      , stage.sbp_expiry  
      , stage.sbp_state  
      , stage.terr_code  
      , stage.desig_code_1  
) THEN  
 UPDATE SET  
  customer.SAGroup = stage.sa_cust  
  , customer.DEALicenseNumber = COALESCE(NULLIF(stage.dea_lic, ''), customer.DEALicenseNumber)  
  , customer.DEALicenseExpiration = COALESCE(NULLIF(stage.dea_expiry, ''), customer.DEALicenseExpiration)  
  , customer.StateLicenseNumber = COALESCE(NULLIF(stage.sbp_lic, ''), customer.StateLicenseNumber)  
  , customer.StateLicenseExpiration = COALESCE(NULLIF(stage.sbp_expiry, ''), customer.StateLicenseExpiration)  
  , customer.StateLicenseState = COALESCE(NULLIF(stage.sbp_state, ''), customer.StateLicenseState)  
  , customer.TerritoryCode = stage.terr_code  
  , customer.ProfessionalDesignation = stage.desig_code_1  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  OrganizationCode  
  , ChargeToNumber  
  , SAGroup  
  , DEALicenseNumber  
  , DEALicenseExpiration  
  , StateLicenseNumber  
  , StateLicenseExpiration  
  , StateLicenseState  
  , TerritoryCode  
  , ProfessionalDesignation  
  , CustomerStatusId  
 )  
 VALUES   
 (  
  stage.org_code  
  , stage.charge_to_num  
  , stage.sa_cust  
  , stage.dea_lic  
  , stage.dea_expiry  
  , stage.sbp_lic  
  , stage.sbp_expiry  
  , stage.sbp_state  
  , stage.terr_code  
  , stage.desig_code_1  
  , 1  
 );

-- Look for duplicate Charge To Numbers  
TRUNCATE TABLE Error_DuplicateChargeTo

INSERT INTO Error_DuplicateChargeTo
    (ChargeToNumber)
SELECT ChargeToNumber
FROM Customer
WHERE COALESCE(ChargeToNumber, '') <> ''
GROUP BY ChargeToNumber
HAVING COUNT(*) > 1

MERGE  [dbo].[CustomerAddress] AS customerAddress  
USING (  
 SELECT cust.CustomerId, stageCust.*
FROM [dbo].[Elite_Stage_Customer] stageCust
    JOIN [dbo].[Customer] cust
    ON cust.OrganizationCode = stageCust.org_code
        AND cust.ChargeToNumber = stageCust.charge_to_num
WHERE charge_to_num NOT IN (  
  SELECT ChargeToNumber
    FROM Error_DuplicateChargeTo  
 )
    AND stageCust.tag = '%s'  
) AS stage  
    ON customerAddress.OrganizationCode = stage.org_code
    AND customerAddress.CustomerNumber = stage.cust_num  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        customerAddress.CustomerId  
      , customerAddress.FullName  
      , customerAddress.Address1  
      , customerAddress.Address2  
      , customerAddress.Address3  
      , customerAddress.City  
      , customerAddress.[State]  
      , customerAddress.Zip  
      , customerAddress.PhoneNumber  
      , customerAddress.FaxNumber  
      , customerAddress.EmailAddress
EXCEPT
    SELECT
        stage.CustomerId   
      , stage.cust_name  
      , stage.address1  
      , stage.address2  
      , stage.address3  
      , stage.city  
      , stage.province  
      , stage.postal_code  
      , stage.phone  
      , stage.fax  
      , stage.email_address  
) THEN  
 UPDATE SET  
  customerAddress.CustomerId = stage.CustomerId  
  , customerAddress.FullName = stage.cust_name  
  , customerAddress.Address1 = stage.address1  
  , customerAddress.Address2 = stage.address2  
  , customerAddress.Address3 = stage.address3  
  , customerAddress.City = stage.city  
  , customerAddress.[State] = stage.province  
  , customerAddress.Zip = stage.postal_code  
  , customerAddress.PhoneNumber = COALESCE(NULLIF(stage.phone, ''), customerAddress.PhoneNumber)  
  , customerAddress.FaxNumber = COALESCE(NULLIF(stage.fax, ''), customerAddress.FaxNumber)  
  , customerAddress.EmailAddress = COALESCE(NULLIF(stage.email_address, ''), customerAddress.EmailAddress)  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  CustomerId  
  , OrganizationCode  
  , CustomerNumber  
  , FullName  
  , Address1  
  , Address2  
  , Address3  
  , City  
  , State  
  , Zip  
  , PhoneNumber  
  , FaxNumber  
  , EmailAddress  
 )  
 VALUES   
 (  
  stage.CustomerId  
  , stage.org_code  
  , stage.cust_num  
  , stage.cust_name  
  , stage.address1  
  , stage.address2  
  , stage.address3  
  , stage.city  
  , stage.province  
  , stage.postal_code  
  , stage.phone  
  , stage.fax  
  , stage.email_address  
 );
]]

EliteStageLoadFromStaging.OrderStatus = [[MERGE  [dbo].[SampleOrder] AS sampleOrder  
USING (  
    -- not cancelled orders  
     SELECT DISTINCT
        org_code  
      , cust_po_num   
      , order_num   
      , order_status   
      , cancel_note  
      , po_status  
      , po_status_desc  
      , hold_code
    FROM [dbo].[Elite_Stage_OrderStatus]
    WHERE cancel_note <> 'CNRE'
        AND order_status <> '4'
        AND tag = '%s'
UNION
    -- cancelled orders not CNRE  
    SELECT DISTINCT
        org_code  
      , cust_po_num   
      , order_num   
      , order_status   
      , cancel_note   
      , po_status  
      , po_status_desc  
      , hold_code
    FROM [dbo].[Elite_Stage_OrderStatus]
    WHERE cancel_note <> 'CNRE'
        AND order_status = '4'
        AND cust_po_num NOT IN   
           (  
            SELECT cust_po_num
                  FROM [dbo].[Elite_Stage_OrderStatus]
                  WHERE cancel_note <> 'CNRE'
                      AND order_status <> '4'  
           )
        AND tag = '%s'
) AS stage  
 ON sampleOrder.OrganizationCode = stage.org_code
    AND sampleOrder.ExternalOrderId = stage.cust_po_num
    AND sampleOrder.ProcessedDate IS NULL -- Ignore Processed Orders  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        sampleOrder.OrderNumber,
        sampleOrder.OrderStatusId
EXCEPT
    SELECT
        stage.order_num,
        CASE   
            WHEN stage.order_status = '1' AND stage.po_status = '1' THEN 2 -- When Open Then Processing  
            WHEN stage.order_status = '1'
                     AND (stage.po_status = '2' OR stage.po_status = '3')
                     AND stage.hold_code IN ('BACH','BACK') THEN 6 -- When Open with Partial or Full Hold and Backorder code Then On Backorder Hold  
            WHEN stage.order_status = '2' THEN 3 -- When Shipped Then Shipped  
            WHEN stage.order_status = '3' THEN 3 -- When Invoiced Then Shipped  
            WHEN stage.order_status = '4' THEN 4 -- When Cancelled Then Rejected  
            ELSE sampleOrder.OrderStatusId -- Otherwise ignore  
        END  
) THEN  
UPDATE SET  
  sampleOrder.OrderNumber = stage.order_num  
  , sampleOrder.OrderStatusId =   
   CASE   
       WHEN stage.order_status = '1' AND stage.po_status = '1' THEN 2 -- When Open Then Processing  
       WHEN stage.order_status = '1'
          AND (stage.po_status = '2' OR stage.po_status = '3')
          AND stage.hold_code IN ('BACH','BACK') THEN 6 -- When Open with Partial or Full Hold and Backorder code Then On Backorder Hold  
       WHEN stage.order_status = '2' THEN 3 -- When Shipped Then Shipped  
       WHEN stage.order_status = '3' THEN 3 -- When Invoiced Then Shipped  
       WHEN stage.order_status = '4' THEN 4 -- When Cancelled Then Rejected  
       ELSE sampleOrder.OrderStatusId  
   END  
  , sampleOrder.OrderStatusReason =   
   CASE   
       WHEN stage.order_status = '1'
          AND (stage.po_status = '2' OR stage.po_status = '3')
          AND stage.hold_code IN ('BACH','BACK') THEN 'BACK'  
       WHEN stage.order_status = '4' THEN stage.cancel_note  
       ELSE ''  
   END  
  , sampleOrder.NotifiedRejection =   
    CASE  
        WHEN sampleOrder.OrderStatusId = 6 AND stage.order_status = '4' THEN 0 --When a backorder has been cancelled, we reset flag so system can generate rejection notification  
        ELSE sampleOrder.NotifiedRejection  
    END  
  , sampleOrder.OrderStatusModifiedDate = GETDATE()  
  , sampleOrder.ModifiedDate = GETDATE(); 
]]

EliteStageLoadFromStaging.Shipment = [[MERGE [dbo].[Shipment] AS shipment  
USING (  
SELECT sampleOrder.OrderId, stageOrder.*
FROM [dbo].[Elite_Stage_Order] stageOrder
    JOIN [dbo].[SampleOrder] sampleOrder
    ON sampleOrder.OrganizationCode = org_code
        AND sampleOrder.ExternalOrderId = cust_po_num
WHERE stageOrder.tag = '%s'
) AS stage  
    ON shipment.OrderId = stage.OrderId
    AND shipment.PPSNumber = stage.pps_num  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
SELECT
    shipment.ShipDate  
  , shipment.ShipViaCode  
  , shipment.ShipViaDescription  
  , shipment.Address1  
  , shipment.Address2  
  , shipment.Address3  
  , shipment.City  
  , shipment.State  
  , shipment.Zip  
  , shipment.FromAddress1  
  , shipment.FromAddress2  
  , shipment.FromAddress3  
  , shipment.FromCity  
  , shipment.FromState  
  , shipment.FromZip  
  , shipment.DeliveryDate  
  , shipment.RecipientName
EXCEPT
SELECT
    stage.shipped_date  
  , stage.ship_via_code  
  , stage.desc_1  
  , stage.address1  
  , stage.address2  
  , stage.address3  
  , stage.city  
  , stage.state  
  , stage.zip  
  , stage.from_address1  
  , stage.from_address2  
  , stage.from_address3  
  , stage.from_city  
  , stage.from_state  
  , stage.from_zip  
  , CASE WHEN stage.delivery_date = '' THEN NULL ELSE stage.delivery_date END as delivery_date  
  , stage.recipient_name  
) THEN  
UPDATE SET  
  shipment.ShipDate = stage.shipped_date  
  , shipment.ShipViaCode = stage.ship_via_code  
  , shipment.ShipViaDescription = stage.desc_1  
  , shipment.Address1 = stage.address1  
  , shipment.Address2 = stage.address2  
  , shipment.Address3 = stage.address3  
  , shipment.City = stage.city  
  , shipment.State = stage.state  
  , shipment.Zip = stage.zip  
  , shipment.FromAddress1 = stage.from_address1  
  , shipment.FromAddress2 = stage.from_address2  
  , shipment.FromAddress3 = stage.from_address3  
  , shipment.FromCity = stage.from_city  
  , shipment.FromState = stage.from_state  
  , shipment.FromZip = stage.from_zip  
  , shipment.DeliveryDate = CASE WHEN stage.delivery_date = '' THEN NULL ELSE stage.delivery_date END  
  , shipment.RecipientName = stage.recipient_name  
  , shipment.ModifiedDate = GETDATE()  
  , shipment.LastModifiedByUser = 'system'  
WHEN NOT MATCHED BY TARGET THEN  
INSERT
    (OrderId
    , PPSNumber
    , ShipDate
    , ShipViaCode
    , ShipViaDescription
    , Address1
    , Address2
    , Address3
    , City
    , State
    , Zip
    , FromAddress1
    , FromAddress2
    , FromAddress3
    , FromCity
    , FromState
    , FromZip
    , ShipmentStatusId
    , DeliveryDate
    , RecipientName
    , LastModifiedByUser
    )
VALUES
    (stage.OrderId  
  , stage.pps_num  
  , stage.shipped_date  
  , stage.ship_via_code  
  , stage.desc_1  
  , stage.address1  
  , stage.address2  
  , stage.address3  
  , stage.city  
  , stage.state  
  , stage.zip  
  , stage.from_address1  
  , stage.from_address2  
  , stage.from_address3  
  , stage.from_city   
  , stage.from_state  
  , stage.from_zip  
  , 1  
  , CASE WHEN stage.delivery_date = '' THEN NULL ELSE stage.delivery_date END  
  , stage.recipient_name  
  , 'system'  
 ); 
]]

EliteStageLoadFromStaging.ShipmentItem = [[-- Added code to fix the duplicate issue for OT when same product is ordered in diffrent lines   
---------------------------------------------------------------------------------------------*/  
DECLARE @TempShipmentItemData TABLE(
    ShipmentId INT,
    ProductId INT,
    ExternalOrderItemId varchar(200),
    org_code varchar(10),
    cust_po_num varchar(200),
    pps_num varchar(200),
    inv_shp_l_id int,
    item_num varchar(200),
    shipped_qty int,
    onhold_qty int,
    sell_uom varchar(200)  
 )

DECLARE @TempShipItemOT TABLE(
    ShipmentId INT,
    ProductId INT,
    org_code varchar(10),
    cust_po_num varchar(200),
    pps_num varchar(200),
    inv_shp_l_id int,
    item_num varchar(200),
    shipped_qty int,
    onhold_qty int,
    sell_uom varchar(200),
    ExternalOrderItemId varchar(200)  
 )

insert into @TempShipmentItemData
    (ShipmentId,ProductId,ExternalOrderItemId,org_code,cust_po_num,pps_num,inv_shp_l_id,item_num, shipped_qty, onhold_qty, sell_uom)
SELECT DISTINCT shipment.ShipmentId, product.ProductId, orderItem.ExternalOrderItemId, org_code, cust_po_num, pps_num, inv_shp_l_id, item_num, shipped_qty, onhold_qty, sell_uom
FROM [dbo].[Elite_Stage_OrderLine] stageOrderLine
    JOIN [dbo].[SampleOrder] sampleOrder
    ON sampleOrder.OrganizationCode = org_code
        AND sampleOrder.ExternalOrderId = cust_po_num
    JOIN [dbo].[Shipment] shipment
    ON shipment.OrderId = sampleOrder.OrderId
        AND shipment.PPSNumber = pps_num
    JOIN [dbo].[Product] product
    ON product.OrganizationCode = org_code
        AND product.ProductNumber = item_num
    LEFT JOIN [dbo].[SampleOrderItem] orderItem
    ON orderItem.OrderId = sampleOrder.OrderId
        AND orderItem.ProductId = product.ProductId
WHERE  Sampleorder.Organizationcode <> 'OT'
    AND stageOrderLine.tag = '%s'

---------------------------------------------------------------- Data for OT---------------------------  
;WITH
    EliteLineData
    AS
    (
        SELECT DISTINCT ROW_NUMBER() OVER (ORDER BY SAMPLEORDER.ORDERID,PRODUCT.PRODUCTID ) AS ROWNUMBER , SAMPLEORDER.ORDERID, SHIPMENT.SHIPMENTID, PRODUCT.PRODUCTID, ORG_CODE,
            CUST_PO_NUM, PPS_NUM, INV_SHP_L_ID, ITEM_NUM, SHIPPED_QTY, ONHOLD_QTY, SELL_UOM
        FROM [DBO].[ELITE_STAGE_ORDERLINE] STAGEORDERLINE
            JOIN [DBO].[SAMPLEORDER] SAMPLEORDER
            ON SAMPLEORDER.ORGANIZATIONCODE = ORG_CODE
                AND SAMPLEORDER.EXTERNALORDERID = CUST_PO_NUM
            JOIN [DBO].[SHIPMENT] SHIPMENT
            ON SHIPMENT.ORDERID = SAMPLEORDER.ORDERID
                AND SHIPMENT.PPSNUMBER = PPS_NUM
            JOIN [DBO].[PRODUCT] PRODUCT
            ON PRODUCT.ORGANIZATIONCODE = ORG_CODE
                AND PRODUCT.PRODUCTNUMBER = ITEM_NUM
        WHERE  Sampleorder.Organizationcode = 'OT'
            AND stageOrderLine.tag = '%s'
    ) ,
    STAGESOI
    AS
    (
        SELECT ROW_NUMBER() OVER (ORDER BY ORDERID, si.productid) AS EOINumber, SI.*
        FROM [SAMPLEORDERITEM] SI
        WHERE ORDERID in (SELECT ORDERID
        FROM EliteLineData)
    )
insert into @TempShipItemOT
    (ShipmentId, ProductId,org_code, cust_po_num, pps_num, inv_shp_l_id, item_num, shipped_qty, onhold_qty, sell_uom, ExternalOrderItemId)
SELECT DISTINCT
    EliteLineData.SHIPMENTID,
    EliteLineData.PRODUCTID,
    ORG_CODE,
    CUST_PO_NUM,
    PPS_NUM,
    INV_SHP_L_ID,
    ITEM_NUM,
    SHIPPED_QTY,
    ONHOLD_QTY,
    SELL_UOM,
    STAGESOI.ExternalOrderItemId
FROM EliteLineData
    INNER JOIN STAGESOI
    ON STAGESOI.EOINUMBER = EliteLineData.ROWNUMBER
        AND STAGESOI.ORDERID=EliteLineData.ORDERID
        AND STAGESOI.PRODUCTID=EliteLineData.PRODUCTID

----------------------------------------------------------------------------------------------  
MERGE  [dbo].[ShipmentItem] AS shipmentItem  
USING (  
 -- Using DISTINCT becasue there could be multiple records with different lots  
     SELECT DISTINCT
        SHIPMENTID,
        PRODUCTID,
        ORG_CODE,
        CUST_PO_NUM,
        PPS_NUM,
        INV_SHP_L_ID,
        ITEM_NUM,
        SHIPPED_QTY,
        ONHOLD_QTY,
        SELL_UOM,
        ExternalOrderItemId
    from @TempShipmentItemData
union
    SELECT DISTINCT
        SHIPMENTID,
        PRODUCTID,
        ORG_CODE,
        CUST_PO_NUM,
        PPS_NUM,
        INV_SHP_L_ID,
        ITEM_NUM,
        SHIPPED_QTY,
        ONHOLD_QTY,
        SELL_UOM,
        ExternalOrderItemId
    from @TempShipItemOT  
) AS stage  
    ON shipmentItem.ShipmentId = stage.ShipmentId
    AND shipmentItem.ProductId = stage.ProductId
    and stage.inv_shp_l_id = shipmentitem.externalshipmentitemid  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        shipmentItem.ExternalShipmentItemId  
  , shipmentItem.UnitOfMeasure  
  , shipmentItem.ShippedQuantity  
  , shipmentItem.OnHoldQuantity  
  , shipmentItem.ExternalOrderItemId
EXCEPT
    SELECT
        stage.inv_shp_l_id   
  , stage.sell_uom  
  , stage.shipped_qty  
  , stage.onhold_qty  
  , stage.ExternalOrderItemId  
) THEN  
 UPDATE SET  
  shipmentItem.ExternalShipmentItemId = stage.inv_shp_l_id  
  , shipmentItem.UnitOfMeasure = stage.sell_uom  
  , shipmentItem.ShippedQuantity = stage.shipped_qty  
  , shipmentItem.OnHoldQuantity = stage.onhold_qty  
  , shipmentItem.ExternalOrderItemId = stage.ExternalOrderItemId  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  ShipmentId  
  , ProductId  
  , ExternalShipmentItemId  
  , UnitOfMeasure  
  , ShippedQuantity  
  , OnHoldQuantity  
  , ExternalOrderItemId  
 )  
 VALUES   
 (  
  stage.ShipmentId  
  , stage.ProductId  
  , stage.inv_shp_l_id  
  , stage.sell_uom  
  , stage.shipped_qty  
  , stage.onhold_qty  
  , stage.ExternalOrderItemId  
 );
]]

EliteStageLoadFromStaging.ShipmentItemLot = [[MERGE  [dbo].[ShipmentItemLot] AS shipmentItemLot  
USING (  
    SELECT shipmentItem.ShipmentItemId, shipment.ShipmentId, product.ProductId, stageOrderLine.*
    FROM [DBO].[ELITE_STAGE_ORDERLINE] STAGEORDERLINE
        INNER JOIN [DBO].[SAMPLEORDER] SAMPLEORDER
        ON SAMPLEORDER.ORGANIZATIONCODE = STAGEORDERLINE.ORG_CODE
            AND SAMPLEORDER.EXTERNALORDERID = STAGEORDERLINE.CUST_PO_NUM
        INNER JOIN [DBO].[SHIPMENT] SHIPMENT
        ON SHIPMENT.ORDERID = SAMPLEORDER.ORDERID
        INNER JOIN [DBO].[SHIPMENTITEM] SHIPMENTITEM
        ON SHIPMENTITEM.SHIPMENTID = SHIPMENT.SHIPMENTID
            AND SHIPMENTITEM.EXTERNALSHIPMENTITEMID = STAGEORDERLINE.INV_SHP_L_ID
        INNER JOIN [DBO].[PRODUCT] PRODUCT
        ON SHIPMENTITEM.PRODUCTID = PRODUCT.PRODUCTID
           AND STAGEORDERLINE.ITEM_NUM = PRODUCT.PRODUCTNUMBER
    WHERE STAGEORDERLINE.tag = '%s'                
) AS stage  
    ON shipmentItemLot.ShipmentItemId = stage.ShipmentItemId
    AND shipmentItemLot.LotNumber = stage.lot_code  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
    SELECT
        shipmentItemLot.LotShippedQuantity
EXCEPT
    SELECT
        stage.lot_shipped_quantity  
) THEN  
 UPDATE SET  
  shipmentItemLot.LotShippedQuantity = stage.lot_shipped_quantity  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  ShipmentItemId  
  , LotNumber  
  , LotShippedQuantity  
 )  
 VALUES   
 (  
  stage.ShipmentItemId  
  , stage.lot_code  
  , stage.lot_shipped_quantity  
 );  
]]

EliteStageLoadFromStaging.ShipmentContainers = [[MERGE  [dbo].[ShipmentContainer] AS container  
USING (  
    SELECT shipment.ShipmentId, stageContainer.*
    FROM [dbo].[Elite_Stage_OrderContainer] stageContainer
        JOIN [dbo].[SampleOrder] sampleOrder
        ON sampleOrder.OrganizationCode = org_code
            AND sampleOrder.ExternalOrderId = cust_po_num
        JOIN [dbo].[Shipment] shipment
        ON shipment.OrderId = sampleOrder.OrderId
            AND shipment.PPSNumber = pps_num
    WHERE  stageContainer.tag = '%s'
) AS stage  
    ON container.ShipmentId = stage.ShipmentId
    AND container.ContainerNumber = stage.container_num  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        container.TrackingNumber
EXCEPT
    SELECT
        stage.tracking_num  
) THEN  
 UPDATE SET  
  container.TrackingNumber = stage.tracking_num  
WHEN NOT MATCHED BY TARGET THEN  
 INSERT (  
  ShipmentId  
  , ContainerNumber  
  , TrackingNumber  
 )  
 VALUES   
 (  
  stage.ShipmentId  
  , stage.container_num  
  , stage.tracking_num  
 );  
]]

EliteStageLoadFromStaging.AORs = [[MERGE  [dbo].[Shipment] AS shipment  
USING (  
    SELECT DISTINCT
        sampleOrder.OrderId,
        stagePdma.org_code,
        stagePdma.order_num,
        stagePdma.pps_num,
        stagePdma.acknowledgement_date,
        stagePdma.is_eAOR
    FROM [dbo].[Elite_Stage_Pdma] stagePdma
        JOIN [dbo].[SampleOrder] sampleOrder
        ON sampleOrder.OrganizationCode = org_code
            AND sampleOrder.OrderNumber = order_num
    WHERE stagePdma.acknowledgement_date <> ''
        AND stagePdma.tag = '%s'
) AS stage  
    ON shipment.OrderId = stage.OrderId
    AND shipment.PPSNumber = stage.pps_num  
WHEN MATCHED AND EXISTS  
(  
 -- This condition will make it such that only changed records are updated  
 -- Due to NULL value checking, this is better than checking each field for equality  
     SELECT
        shipment.AcknowledgementDate
EXCEPT
    SELECT
        stage.acknowledgement_date  
) THEN  
 UPDATE SET  
  shipment.AcknowledgementDate = stage.acknowledgement_date,  
  shipment.ShipmentStatusId =   
   CASE   
    WHEN stage.is_eAOR = '1' THEN 4 --Complete  
    ELSE 3 --Acknowledged  
   END;  
]]

return EliteStageLoadFromStaging