function Deploy-NetworkNic()
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
    $NicName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetResourceId,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableAcceleratedNetworking = $false,
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAllocationMethod = "Dynamic",
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAddress = "",
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateIpAddressVersion = "IPv4",
    [Parameter(Mandatory = $false)]
    [string]
    $PublicIpResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $IpConfigName = "",
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy NIC $NicName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NicName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    networkInterfaceName="$NicName" `
    subnetResourceId="$SubnetResourceId" `
    enableAcceleratedNetworking="$EnableAcceleratedNetworking" `
    privateIpAllocationMethod="$PrivateIpAllocationMethod" `
    privateIpAddress="$PrivateIpAddress" `
    privateIpAddressVersion="$PrivateIpAddressVersion" `
    publicIpResourceId="$PublicIpResourceId" `
    ipConfigName="$IpConfigName" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkSecurityGroup() {
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
    $NSGName,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy NSG $NSGName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NSGName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    nsgName="$NSGName" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkSecurityGroupRule() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGRuleName,
    [Parameter(Mandatory = $false)]
    [string]
    $Description = "",
    [Parameter(Mandatory = $false)]
    [int]
    $Priority = 200,
    [Parameter(Mandatory = $false)]
    [string]
    $Direction = "Inbound",
    [Parameter(Mandatory = $false)]
    [string]
    $Access = "Deny",
    [Parameter(Mandatory = $false)]
    [string]
    $Protocol = "Tcp",
    [Parameter(Mandatory = $false)]
    [string]
    $SourceAddressPrefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $SourceAddressPrefixes = "",
    [Parameter(Mandatory = $false)]
    [string]
    $SourcePortRange = "*",
    [Parameter(Mandatory = $false)]
    [string]
    $SourcePortRanges = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationAddressPrefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationAddressPrefixes = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRange = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DestinationPortRanges = ""
  )

  Write-Debug -Debug:$true -Message "Deploy NSG Rule $NSGRuleName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$NSGRuleName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    nsgName="$NSGName" `
    nsgRuleName="$NSGRuleName" `
    description="$Description" `
    priority="$Priority" `
    direction="$Direction" `
    access="$Access" `
    protocol="$Protocol" `
    sourceAddressPrefix="$SourceAddressPrefix" `
    sourceAddressPrefixes="$SourceAddressPrefixes" `
    sourcePortRange="$SourcePortRange" `
    sourcePortRanges="$SourcePortRanges" `
    destinationAddressPrefix="$DestinationAddressPrefix" `
    destinationAddressPrefixes="$DestinationAddressPrefixes" `
    destinationPortRange="$DestinationPortRange" `
    destinationPortRanges="$DestinationPortRanges" `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkPublicIp()
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
    $PublicIpAddressName,
    [Parameter(Mandatory = $true)]
    [string]
    $PublicIpAddressType,
    [Parameter(Mandatory = $true)]
    [string]
    $PublicIpAddressSku,
    [Parameter(Mandatory = $false)]
    [string]
    $HostName = "",
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )
  Write-Debug -Debug:$true -Message "Deploy PIP $PublicIpAddressName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PublicIpAddressName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    publicIpName="$PublicIpAddressName" `
    publicIpType="$PublicIpAddressType" `
    publicIpSku="$PublicIpAddressSku" `
    domainNameLabel="$HostName" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json
  
  return $output
}

function Deploy-NetworkPrivateDnsZone()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DnsZoneName,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zone $DnsZoneName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DnsZoneName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateDnsZoneName="$DnsZoneName" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkPrivateDnsZones()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigMain,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zones and VNet links"

  # Get the private DNS zone property names from the ConfigConstants object
  # Do this so we don't hard-code DNS zone names here, just grab whatever is configured on the config...
  $privateDnsZonePropNames = $ConfigConstants `
   | Get-Member -MemberType NoteProperty `
   | Select-Object -ExpandProperty Name `
   | Where-Object { $_.StartsWith("PrivateDnsZoneName") }


  $VNetResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $VNetName

  foreach ($privateDnsZonePropName in $privateDnsZonePropNames)
  {
    $zoneName = $ConfigConstants.$privateDnsZonePropName # Look it up - PSCustomObject... https://learn.microsoft.com/powershell/scripting/learn/deep-dives/everything-about-pscustomobject#dynamically-accessing-properties

    $output = Deploy-NetworkPrivateDnsZone `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.json") `
      -DnsZoneName $zoneName `
      -Tags $Tags

    Write-Debug -Debug:$true -Message "$output"

    $output = Deploy-NetworkPrivateDnsZoneVNetLink `
      -SubscriptionId $SubscriptionId `
      -ResourceGroupName $ResourceGroupName `
      -TemplateUri ($ConfigConstants.TemplateUriPrefix + "net.private-dns-zone.vnet-link.json") `
      -DnsZoneName $zoneName `
      -VNetResourceId $VNetResourceId `
      -Tags $Tags

    Write-Debug -Debug:$true -Message "$output"
  }
}

function Deploy-NetworkPrivateDnsZoneVNetLink()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $DnsZoneName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetResourceId,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy Private DNS Zone VNet Link $DnsZoneName to $VNetResourceId"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$DnsZoneName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateDnsZoneName="$DnsZoneName" `
    vnetResourceId="$VNetResourceId" `
    enableAutoRegistration=$false `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkPrivateEndpointAndNic()
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
    $ProtectedWorkloadResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ProtectedWorkloadSubResource,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateEndpointName,
    [Parameter(Mandatory = $true)]
    [string]
    $NetworkInterfaceName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetResourceId,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy Private Endpoint and NIC $PrivateEndpointName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateEndpointName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    protectedWorkloadResourceId="$ProtectedWorkloadResourceId" `
    protectedWorkloadSubResource="$ProtectedWorkloadSubResource" `
    privateEndpointName="$PrivateEndpointName" `
    networkInterfaceName="$NetworkInterfaceName" `
    subnetResourceId="$SubnetResourceId" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  Write-Debug -Debug:$true -Message "Wait for NIC provisioning to complete"
  Watch-NetworkNicUntilProvisionSuccess `
    -SubscriptionID "$SubscriptionId" `
    -ResourceGroupName "$ResourceGroupName" `
    -NetworkInterfaceName "$NetworkInterfaceName"

  return $output
}

function Deploy-NetworkPrivateEndpointPrivateDnsZoneGroup()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateEndpointName,
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateDnsZoneName,
    [Parameter(Mandatory = $false)]
    [string]
    $PrivateDnsZoneGroupName = "default",
    [Parameter(Mandatory = $true)]
    [string]
    $PrivateDnsZoneResourceId
  )

  Write-Debug -Debug:$true -Message "Deploy Private Endpoint $PrivateEndpointName DNS Zone Group for $PrivateDnsZoneName"

  $zoneName = $PrivateDnsZoneName.Replace(".", "_")

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$PrivateEndpointName-DNSZone" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    privateEndpointName="$PrivateEndpointName" `
    privateDnsZoneName="$zoneName" `
    privateDnsZoneGroupName="$PrivateDnsZoneGroupName" `
    privateDnsZoneResourceId="$PrivateDnsZoneResourceId" `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkSubnet() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetName,
    [Parameter(Mandatory = $true)]
    [string]
    $SubnetPrefix,
    [Parameter(Mandatory = $false)]
    [string]
    $NSGResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $RouteTableResourceId = "",
    [Parameter(Mandatory = $false)]
    [string]
    $DelegationService = "",
    [Parameter(Mandatory = $false)]
    [string]
    $ServiceEndpoints = ""
  )

  Write-Debug -Debug:$true -Message "Deploy Subnet $SubnetName"

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$SubnetName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    vnetName="$VNetName" `
    subnetName="$SubnetName" `
    subnetPrefix="$SubnetPrefix" `
    nsgResourceId="$NSGResourceId" `
    routeTableResourceId="$RouteTableResourceId" `
    delegationService="$DelegationService" `
    serviceEndpoints="$ServiceEndpoints" `
    | ConvertFrom-Json

  return $output
}

function Deploy-NetworkVNet() {
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
    $VNetName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetPrefix,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableDdosProtection = $false,
    [Parameter(Mandatory = $false)]
    [bool]
    $EnableVmProtection = $false,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy VNet $VNetName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$VNetName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    vnetName="$VNetName" `
    vnetPrefix="$VNetPrefix" `
    enableDdosProtection="$EnableDdosProtection" `
    enableVmProtection="$EnableVmProtection" `
    tags=$tagsForTemplate `
    | ConvertFrom-Json

  return $output
}

function Get-MyCurrentPublicIpAddress()
{
  $ipAddress = Invoke-RestMethod https://ipinfo.io/json | Select-Object -exp ip

  return $ipAddress
}

function Get-NetworkSubnetResourceIdForPrivateEndpoint()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigMain,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName
  )

  Write-Debug -Debug:$true -Message "Get Subnet Resource ID for Private Endpoint"

  $result = ""

  $subnetResourceIds = Get-NetworkSubnetResourceIds -ConfigConstants $ConfigConstants -ConfigMain $ConfigMain -SubscriptionId $SubscriptionId -ResourceGroupName "$ResourceGroupName" -VNetName $VNetName

  if ($subnetResourceIds -is [Array])
  {
    $result = $subnetResourceIds[0]
  }
  else
  {
    $result = $subnetResourceIds
  }

  return $result
}

function Get-NetworkSubnetResourceIds()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigConstants,
    [Parameter(Mandatory = $true)]
    [object]
    $ConfigMain,
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $VNetName
  )

  Write-Debug -Debug:$true -Message "Get Subnet Resource IDs"

  $result = [System.Collections.ArrayList]@()

  $vnet = $ConfigMain.Network.VNet
  $VNetResourceId = Get-ResourceId -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -ResourceProviderName "Microsoft.Network" -ResourceTypeName "virtualNetworks" -ResourceName $VNetName

  foreach ($subnet in $vnet.Subnets)
  {
    $subnetResourceId = Get-ChildResourceId -ParentResourceId $VNetResourceId -ChildResourceTypeName "subnets" -ChildResourceName $subnet.Name

    $result.Add($subnetResourceId) | Out-Null
  }

  return $result
}

function Remove-NetworkSecurityGroupRule() {
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGName,
    [Parameter(Mandatory = $true)]
    [string]
    $NSGRuleName
  )

  Write-Debug -Debug:$true -Message "Remove NSG Rule $NSGName/$NSGRuleName"

  $output = az network nsg rule delete --verbose `
    --subscription "$SubscriptionId" `
    -g "$ResourceGroupName" `
    --nsg-name "$NSGName" `
    --name "$NSGRuleName" `
    | ConvertFrom-Json

  return $output
}

function Watch-NetworkNicUntilProvisionSuccess()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $NetworkInterfaceName
  )

  Write-Debug -Debug:$true -Message "Watch NIC $NetworkInterfaceName until ProvisioningStage=Succeeded"

  $limit = (Get-Date).AddMinutes(55)

  $currentState = ""
  $targetState = "Succeeded"

  while ( ($currentState -ne $targetState) -and ((Get-Date) -le $limit) )
  {
    $currentState = "$(az network nic show --subscription $SubscriptionId -g $ResourceGroupName -n $NetworkInterfaceName -o tsv --query 'provisioningState')"

    Write-Debug -Debug:$true -Message "currentState = $currentState"

    if ($currentState -ne $targetState)
    {
      Start-Sleep -s 15
    }
  }

  return $currentState
}
