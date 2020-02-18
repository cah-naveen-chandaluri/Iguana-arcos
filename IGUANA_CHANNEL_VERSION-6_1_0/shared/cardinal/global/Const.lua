-- Copyright © 2019 TECSYS Inc. All rights reserved.
-- Copyright © 2019 TECSYS Inc. Tous droits réservés.

INTERFACE_QUALIFIER = 'interface'
INTERFACE_DB = 'meta96'

SPS_QUALIFIER ='spscommon'
SPS_DB = 'spscommon'

SMS_QUALIFIER ='cah_sms'
SMS_DB = 'cah_sms'

EXCEPTION = {["Checked"]=1, ["Unchecked"]=2}

PROJECT = {["OPTXT"] = "OPTXT", ["SFTP"] = "SFTP", ["SMS"] = "SMS", ["OUTBOUND"] = "OUTBOUND", ["CCID"] = "CCID"}

--HTTP
HTTPCODE = {["Success"] = 200, ["Unauthorized"] = 401, ["NotFound"] = 404, ["ServerError"] = 500, isSuccess = function(arg) return arg == 200 end}
REQ_METHOD = {["GET"] = "GET", ["POST"] = "POST", ["PUT"] = "PUT", ["DELETE"] = "DELETE"}
CONTENT_TYPE = {["PLAIN"] = "text/plain", ["XML"] = "text/xml", ["HTML"] = "text/html", ["JSON-APP"] = "application/json"}


INTERFACE_VIEW_ALTID = "MetaInterfaceFileCe-Webservice"
