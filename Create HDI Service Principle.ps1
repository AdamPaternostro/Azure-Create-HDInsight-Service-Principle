# Creates a new certificate and creates a service principle for HDI
# https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-authenticate-service-principal
# https://technet.microsoft.com/en-us/library/hh848633.aspx
# https://technet.microsoft.com/en-us/library/hh848635.aspx

$azureApplicationName="<<REMOVED e.g. MyHDICluster >>"
$certificatePassword="<<REMOVED>>"
$subscriptionId = "<<REMOVED>>"

# Connect to Azure
Login-AzureRmAccount
$Sub = Select-AzureRmSubscription -SubscriptionId $subscriptionId

# Create the certificate
$subject="CN=" + $azureApplicationName
$cert = New-SelfSignedCertificate -CertStoreLocation "cert:\CurrentUser\My" -Subject $subject -KeySpec KeyExchange
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

# Create the Azure application
$uri="https://" + $azureApplicationName + ".com"
$app = New-AzureRmADApplication -DisplayName $azureApplicationName -HomePage $uri -IdentifierUris $uri -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore
New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId

# Export the certificate to the desktop
$mypwd = ConvertTo-SecureString -String $certificatePassword -Force –AsPlainText
$desktopPath = [Environment]::GetFolderPath("Desktop") + "\" + $azureApplicationName + ".pfx"
Export-PfxCertificate -Cert $cert -FilePath $desktopPath -Password $mypwd

# When the developers select the certificate in the Portal (HDInsights w/data lake) 
$json = '"clusterIdentity": {
               "clusterIdentity.applicationId": "' + $app.ApplicationId + '",
               "clusterIdentity.certificate": "' + $keyValue + '",
               "clusterIdentity.aadTenantId": "https://login.windows.net/' + $Sub.Tenant + '",
               "clusterIdentity.resourceUri": "https://management.core.windows.net/",
               "clusterIdentity.certificatePassword": "' + $certificatePassword + '"
              }'


Write-Output $json



