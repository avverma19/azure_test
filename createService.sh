#!/bin/bash

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

mkdir /opt/scripts
cat <<'EndOfContent' >/opt/scripts/customization.sh
#!/bin/bash

#  Get Paramaters Values
containerName=$1
accountName=$2

#  Get token expiry
end=$(date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ')

# Login To Azure using identity
az login --identity

#  Blob exists
existVal=$(az storage blob exists --container-name $containerName --account-name $accountName --name jasperserver.license | grep 'exists' | sed -r 's/^[^:]*:(.*)$/\1/' | xargs)

if [ $existVal == 'true' ]
then
# Download the blob files 
az storage blob download --container-name $containerName --account-name $accountName -n jasperserver.license -f /opt/jaspersoft/tomcat/webapps/jasperserver-pro/WEB-INF/jasperserver.license
fi

az storage blob download-batch -d /opt/jaspersoft/tomcat/webapps/ -s $containerName --account-name $accountName

# Logout from Azure
az logout
sudo /opt/jaspersoft/tomcat/bin/shutdown.sh
sudo /opt/jaspersoft/tomcat/bin/startup.sh
EndOfContent

cat <<EndOfMessage >/opt/scripts/customizationService.service
[Unit]
Description= testing service

[Service]
ExecStart=sudo bash /opt/scripts/customization.sh $1 $2

[Install]
WantedBy=multi-user.target
EndOfMessage

chmod 664 /opt/scripts/customizationService.service
cp /opt/scripts/customizationService.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable customizationService.service
