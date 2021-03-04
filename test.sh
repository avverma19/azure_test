#!/bin/bash


#  Get token expiry
end=$(date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ')


#  Checking initialization marker to skip commands
initializationMarker=$(test ! -e /home/bitnami/initializationMarker.log && echo "0"|| echo "1")
if [ $initializationMarker == 0 ]
then
echo "Current date: $end"
fi

# Login To Azure using identity
az login --identity

# Generate SAS Token to access BLOB
az storage container generate-sas --name avtest2storagelicensecontainer --account-name avtest2storagelicense --expiry $end --https-only --permissions dlrw

#az storage blob list --container-name avtest2storagelicensecontainer --account-name avtest2storagelicense

#  Blob exists
existVal=$(az storage blob exists --container-name avtest2storagelicensecontainer --account-name avtest2storagelicense --name template.json | grep 'exists' | sed -r 's/^[^:]*:(.*)$/\1/' | xargs)

if [ $existVal == 'true' ]
then
echo "Current date: $end"
# Download the blob files 
az storage blob download --container-name avtest2storagelicensecontainer --account-name avtest2storagelicense -n template.json -f /home/avadmin/template.json
fi

#  Create initialization marker
echo "Initialization complete. Initialization commands will be blocked." > /home/bitnami/initializationMarker.log

# Logout from Azure
az logout
