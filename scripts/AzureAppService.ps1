function Deploy-AppInsights()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppInsightsName,
    [Parameter(Mandatory = $true)]
    [string]
    $LogAnalyticsWorkspaceId,
    [Parameter(Mandatory = $false)]
    [string]
    $LinkedStorageAccountId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForIngestion = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccessForQuery = "Enabled",
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy App Insights $AppInsightsName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppInsightsName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appInsightsName="$AppInsightsName" `
    logAnalyticsWorkspaceId="$LogAnalyticsWorkspaceId" `
    linkedStorageAccountId="$LinkedStorageAccountId" `
    publicNetworkAccessForIngestion="$PublicNetworkAccessForIngestion" `
    publicNetworkAccessForQuery="$PublicNetworkAccessForQuery" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServiceCertificate()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServiceCertificateName,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $KeyVaultSecretName,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Certificate $AppServiceCertificateName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServiceCertificateName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    certificateName="$AppServiceCertificateName" `
    keyVaultResourceId="$KeyVaultResourceId" `
    keyVaultSecretName="$KeyVaultSecretName" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppService()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServiceName,
    [Parameter(Mandatory = $true)]
    [string]
    $Kind,
    [Parameter(Mandatory = $false)]
    [bool]
    $AssignSystemIdentity = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $UserAssignedIdentityResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $UserAssignedIdentityClientId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AppServicePlanResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $AppInsightsResourceId = "",
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountId,
    [Parameter(Mandatory = $true)]
    [string]
    $StorageAccountName,
    [Parameter(Mandatory = $false)]
    [string]
    $FunctionRuntimeVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $FunctionRuntimeWorker = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Language = "",
    [Parameter(Mandatory = $false)]
    [string]
    $LinuxFxVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DotnetVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PythonVersion = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicNetworkAccess = "Disabled",
    [Parameter(Mandatory = $false)]
    [string]
    $SubnetResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $RouteAllTrafficThroughVNet = $true,
    [Parameter(Mandatory = $false)]
    [string]
    $AllowedIpAddressRanges = "",
    [Parameter(Mandatory = $false)]
    [string]
    $CustomFqdn = "",
    [Parameter(Mandatory = $false)]
    [string]
    $CertificateForAppServiceThumbprint = "",
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy App Service $AppServiceName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServiceName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServiceName="$AppServiceName" `
    kind="$Kind" `
    assignSystemIdentity="$AssignSystemIdentity" `
    userAssignedIdentityResourceId="$UserAssignedIdentityResourceId" `
    userAssignedIdentityClientId="$UserAssignedIdentityClientId" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    appInsightsResourceId="$AppInsightsResourceId" `
    storageAccountId="$StorageAccountId" `
    storageAccountName="$StorageAccountName" `
    functionRuntimeVersion="$FunctionRuntimeVersion" `
    functionRuntimeWorker="$FunctionRuntimeWorker" `
    language="$Language" `
    linuxFxVersion="$LinuxFxVersion" `
    dotnetVersion="$DotnetVersion" `
    pythonVersion="$PythonVersion" `
    publicNetworkAccess="$PublicNetworkAccess" `
    subnetResourceId="$SubnetResourceId" `
    routeAllTrafficThroughVNet="$RouteAllTrafficThroughVNet" `
    allowedIpAddressRanges="$AllowedIpAddressRanges" `
    customFqdn="$CustomFqdn" `
    certificateForAppServiceThumbprint="$CertificateForAppServiceThumbprint" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServicePlan()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanName,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuName,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuTier,
    [Parameter(Mandatory = $true)]
    [string]
    $SkuFamily,
    [Parameter(Mandatory = $true)]
    [string]
    $Capacity,
    [Parameter(Mandatory = $true)]
    [string]
    $Kind,
    [Parameter(Mandatory = $false)]
    [bool]
    $ZoneRedundant = $true,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Plan $AppServicePlanName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AppServicePlanName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    appServicePlanName="$AppServicePlanName" `
    skuName="$SkuName" `
    skuTier="$SkuTier" `
    skuFamily="$SkuFamily" `
    capacity="$Capacity" `
    kind="$Kind" `
    zoneRedundant="$ZoneRedundant" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-AppServicePlanAutoscaleSettings()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $AutoscaleSettingsName,
    [Parameter(Mandatory = $true)]
    [string]
    $AppServicePlanResourceId,
    [Parameter(Mandatory = $true)]
    [int]
    $MinimumInstances,
    [Parameter(Mandatory = $true)]
    [int]
    $MaximumInstances,
    [Parameter(Mandatory = $true)]
    [int]
    $DefaultInstances,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy App Service Plan Autoscale Settings $AutoscaleSettingsName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$AutoscaleSettingsName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    autoScaleSettingsName="$AutoscaleSettingsName" `
    appServicePlanResourceId="$AppServicePlanResourceId" `
    minimumInstances="$MinimumInstances" `
    maximumInstances="$MaximumInstances" `
    defaultInstances="$DefaultInstances" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}
