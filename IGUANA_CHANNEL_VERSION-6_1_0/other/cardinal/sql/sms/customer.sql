/*
select trim(org_code) org_code,
       trim(cust_num) cust_num,
       trim(charge_to) charge_to,
       trim(cust_name) cust_name,
       trim(address1) address1,
       trim(address2) address2,
       trim(address3) address3,
       trim(city) city,
       trim(province) province,
       trim(postal_code) postal_code,
       trim(phone) phone,
       trim(fax) fax,
       trim(email_address) email_address,
       trim(sa_cust) sa_cust,
       trim(dea_license) dea_license,
       trim(dea_expiry) dea_expiry,
       trim(sbp_lic) sbp_lic,
       trim(sbp_state) sbp_state,
       trim(sbp_expiry) sbp_expiry,
       trim(terr_code) terr_code,
       trim(Professional_Designation) Professional_Designation
FROM (       
SELECT distinct 
		--substr(cust.cust_num, 1, 2) org_code,
		 cust_org.org_code,
         cust.cust_num,
         cust.CHARGE_TO,
         cust.cust_name,
         cust.address1,
         cust.address2,
         cust.address3,
         cust.city,
         cust.province,
         cust.postal_code,
         cust.phone,
         cust.fax,
       	 '' as email_address,
         cust.sa_cust,
         cust_lic.dea_license,
         nvl2(cust_lic.dea_expiry, to_char(cust_lic.dea_expiry,'mm/dd/yyyy'),null) as dea_expiry,
         cust_lic.sbp_lic,
         cust_lic.sbp_state,
         nvl2(cust_lic.sbp_expiry, to_char(cust_lic.sbp_expiry,'mm/dd/yyyy'),null) as sbp_expiry,
         cust.terr_code,
         nvl(cust_lic.dea_design_code, cust_lic.sbp_design_code) as Professional_Designation
    FROM d_customer cust
	INNER JOIN d_customer_org cust_org 
	  ON cust.cust_num = cust_org.cust_num
	INNER JOIN sps_sms_org_codes sms 
	  ON (cust_org.org_code = sms.org_code AND sms.active = 1)
    LEFT OUTER JOIN sms_cust_license cust_lic
      ON cust.cust_num = cust_lic.cust_num
   -- LEFT JOIN D_CUSTOMER_CONTACT cc
    --  ON cc.cust_num = cust.cust_num
    --LEFT JOIN D_CONTACT c
    --  ON cc.contact_code = c.contact_code	  
WHERE 
EXISTS
( SELECT 1
FROM d_ord o
INNER JOIN sps_sms_org_codes sms
ON (o.org_code         = sms.org_code AND sms.active             = 1)
WHERE sms.active           = 1
AND cust.cust_num=o.cust_num
AND cust_org.org_code=o.org_code
AND o.ORIG_ORDER_TYPE  IN('DTP', 'DTPM')
AND trunc(o.ORDER_DATE) >= trunc(sysdate)-10
) 
AND sms.active               = 1 
--AND cust.stat='P'
);
*/
select trim('U1') org_code,
       trim('CFT1') cust_num,
       trim('CFT') charge_to,
       trim('CFT') cust_name,
       trim('123 address') address1,
       trim('222 address') address2,
       trim('33 address') address3,
       trim('MTL') city,
       trim('QC') province,
       trim('H0H0H0') postal_code,
       trim('514-555-7777') phone,
       trim('') fax,
       trim('') email_address,
       trim('') sa_cust,
       trim('') dea_license,
       trim('') dea_expiry,
       trim('') sbp_lic,
       trim('') sbp_state,
       trim('') sbp_expiry,
       trim('') terr_code,
       trim('') Professional_Designation
FROm dual;