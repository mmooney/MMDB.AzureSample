#Modified and simplified version of https://www.windowsazure.com/en-us/develop/net/common-tasks/continuous-delivery/
#From: #https://gist.github.com/4539567
$subscription = "3-Month Free Trial" #this the name from your .publishsettings file
$service = "mmdbazuresample" #this is the name of the cloud service you created
$storageAccount = "mmdbazuresamplestorage" #this is the name of the storage service you created
$slot = "production" #staging or production
$package = "C:\Projects\MMDB.AzureSample\MMDB.AzureSample.Web.Azure\bin\Release\app.publish\MMDB.AzureSample.Web.Azure.cspkg"
$configuration = "C:\Projects\MMDB.AzureSample\MMDB.AzureSample.Web.Azure\bin\Release\app.publish\ServiceConfiguration.Cloud.cscfg"
$publishSettingsFile = "Azure.publishsettings"
$timeStampFormat = "g"
$deploymentLabel = "PowerShell Deploy to $service"
 
Write-Output "Slot: $slot"
Write-Output "Subscription: $subscription"
Write-Output "Service: $service"
Write-Output "Storage Account: $storageAccount"
Write-Output "Slot: $slot"
Write-Output "Package: $package"
Write-Output "Configuration: $configuration"

Write-Output "Running Azure Imports"
Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\*.psd1"
Import-AzurePublishSettingsFile $publishSettingsFile
Set-AzureSubscription -CurrentStorageAccount $storageAccount -SubscriptionName $subscription
Set-AzureService -ServiceName $service -Label $deploymentLabel
 
function Publish(){
 $deployment = Get-AzureDeployment -ServiceName $service -Slot $slot -ErrorVariable a -ErrorAction silentlycontinue 
 
 if ($a[0] -ne $null) {
    Write-Output "$(Get-Date -f $timeStampFormat) - No deployment is detected. Creating a new deployment. "
 }
 
 if ($deployment.Name -ne $null) {
    #Update deployment inplace (usually faster, cheaper, won't destroy VIP)
    Write-Output "$(Get-Date -f $timeStampFormat) - Deployment exists in $servicename.  Upgrading deployment."
    UpgradeDeployment
 } else {
    CreateNewDeployment
 }
}
 
function CreateNewDeployment()
{
    write-progress -id 3 -activity "Creating New Deployment" -Status "In progress"
    Write-Output "$(Get-Date -f $timeStampFormat) - Creating New Deployment: In progress"
 
    $opstat = New-AzureDeployment -Slot $slot -Package $package -Configuration $configuration -label $deploymentLabel -ServiceName $service
 
    $completeDeployment = Get-AzureDeployment -ServiceName $service -Slot $slot
    $completeDeploymentID = $completeDeployment.deploymentid
 
    write-progress -id 3 -activity "Creating New Deployment" -completed -Status "Complete"
    Write-Output "$(Get-Date -f $timeStampFormat) - Creating New Deployment: Complete, Deployment ID: $completeDeploymentID"
}
 
function UpgradeDeployment()
{
    write-progress -id 3 -activity "Upgrading Deployment" -Status "In progress"
    Write-Output "$(Get-Date -f $timeStampFormat) - Upgrading Deployment: In progress"
 
    # perform Update-Deployment
    $setdeployment = Set-AzureDeployment -Upgrade -Slot $slot -Package $package -Configuration $configuration -label $deploymentLabel -ServiceName $service -Force
 
    $completeDeployment = Get-AzureDeployment -ServiceName $service -Slot $slot
    $completeDeploymentID = $completeDeployment.deploymentid
 
    write-progress -id 3 -activity "Upgrading Deployment" -completed -Status "Complete"
    Write-Output "$(Get-Date -f $timeStampFormat) - Upgrading Deployment: Complete, Deployment ID: $completeDeploymentID"
}
 
Write-Output "Create Azure Deployment"
Publish