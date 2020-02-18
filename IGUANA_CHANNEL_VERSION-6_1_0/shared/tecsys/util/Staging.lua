-- Copyright © 2015 TECSYS Inc. All rights reserved.
-- Copyright © 2015 TECSYS Inc. Tous droits réservés.

Staging = {
   Action = {CREATE='1', UPDATE='2', DELETE='3', CREATE_OR_UPDATE='4', CREATE_OR_REPLACE='5'}, 
   Status = {HOLD='1', READY_FOR_TRANSFER='2', TRANSFERRED='3', TRANSFERRED_WITH_WARNING='4', IN_ERROR='5'},
   StatusChild = {SAMEASPARENT='1', DONOTTRANSFER='2'}
}

return Staging