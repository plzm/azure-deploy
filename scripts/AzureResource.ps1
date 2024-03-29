function Get-ChildResourceId()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $ParentResourceId,
    [Parameter(Mandatory = $true)]
    [string]
    $ChildResourceTypeName,
    [Parameter(Mandatory = $true)]
    [string]
    $ChildResourceName
  )

  Write-Debug -Debug:$true -Message ("Get-ChildResourceId: ParentResourceId: " + "$ParentResourceId" + ", ChildResourceTypeName: " + "$ChildResourceTypeName" + ", ChildResourceName: " + "$ChildResourceName")

  $result = $ParentResourceId + "/" + $ChildResourceTypeName + "/" + $ChildResourceName

  return $result
}

function Get-ResourceId()
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
    $ResourceProviderName,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceTypeName,
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceSubTypeName = "",
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceName,
    [Parameter(Mandatory = $false)]
    [string]
    $ChildResourceTypeName = "",
    [Parameter(Mandatory = $false)]
    [string]
    $ChildResourceName = ""
  )

  Write-Debug -Debug:$true -Message ("Get-ResourceId: SubscriptionId: " + "$SubscriptionId" + ", ResourceGroupName: " + "$ResourceGroupName" + ", ResourceProviderName: " + "$ResourceProviderName" + ", ResourceTypeName: " + "$ResourceTypeName" + ", ResourceName: " + "$ResourceName" + ", ChildResourceTypeName: " + "$ChildResourceTypeName" + ", ChildResourceName: " + "$ChildResourceName")

  $result = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" + $ResourceGroupName + "/providers/" + $ResourceProviderName + "/" + $ResourceTypeName + "/"
  
  if ($ResourceSubTypeName)
  {
    $result += $ResourceSubTypeName + "/"
  }

  $result += $ResourceName

  if ($ChildResourceTypeName -and $ChildResourceName)
  {
    $result += "/" + $ChildResourceTypeName + "/" + $ChildResourceName
  }

  return $result
}

function Get-ResourceName()
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
    [Parameter(Mandatory = $false)]
    [string]
    $Prefix = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Sequence = "",
    [Parameter(Mandatory = $false)]
    [string]
    $Suffix = "",
    [Parameter(Mandatory = $false)]
    [bool]
    $IncludeDelimiter = $true
  )

  Write-Debug -Debug:$true -Message ("Get-ResourceName: Prefix: " + "$Prefix" + ", Sequence: " + "$Sequence" + ", Suffix: " + "$Suffix" + ", IncludeDelimiter: " + "$IncludeDelimiter")

  if ($IncludeDelimiter)
  {
    $delimiter = "-"
  }
  else
  {
    $delimiter = ""
  }

  $result = ""

  if ($ConfigConstants.NamePrefix) { $result = $ConfigConstants.NamePrefix }
  if ($ConfigConstants.NameInfix) { $result += $delimiter + $ConfigConstants.NameInfix }

  if ($ConfigMain.LocationShort) { $result += $delimiter + $ConfigMain.LocationShort}

  if ($Prefix) { $result = $Prefix + $delimiter + $result }
  if ($Sequence) { $result += $delimiter + $Sequence }
  if ($Suffix) { $result += $delimiter + $Suffix }

  return $result
}

function Get-Resources()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory = $false)]
    [string]
    $ResourceGroupName = "",
    [Parameter(Mandatory = $false)]
    [boolean]
    $AddChildResources = $false
  )

  Write-Debug -Debug:$true -Message ("Get-Resources: SubscriptionId: " + "$SubscriptionId" + ", ResourceGroupName: " + "$ResourceGroupName")

  [System.Collections.ArrayList]$resources = @()

  if (!$ResourceGroupName)
  {
    $result = "$(az resource list --subscription $SubscriptionId --query '[].{name:name, id:id, resourceGroup:resourceGroup}')" | ConvertFrom-Json
  }
  else
  {
    $result = "$(az resource list --subscription $SubscriptionId -g $ResourceGroupName --query '[].{name:name, id:id, resourceGroup:resourceGroup}')" | ConvertFrom-Json
  }

  foreach ($ro in $result)
  {
    $resources.Add($ro) | Out-Null
  }

  if ($AddChildResources)
  {
    [System.Collections.ArrayList]$childResources = @()

    foreach ($resource in $resources)
    {
      $resourceId = $resource.id

      if ($resourceId.EndsWith("Microsoft.Storage/storageAccounts/" + $resource.name))
      {
        $childNameSuffix = "/blobServices/default"
        $childName = $resource.name + $childNameSuffix
        $childId = $resourceId + $childNameSuffix
        $ro = New-Object PSCustomObject -Property @{ name = $childName; id = $childId; resourceGroup = $resource.resourceGroup }
        $childResources.Add($ro) | Out-Null
    
        $childNameSuffix = "/fileServices/default"
        $childName = $resource.name + $childNameSuffix
        $childId = $resourceId + $childNameSuffix
        $ro = New-Object PSCustomObject -Property @{ name = $childName; id = $childId; resourceGroup = $resource.resourceGroup }
        $childResources.Add($ro) | Out-Null
    
        $childNameSuffix = "/queueServices/default"
        $childName = $resource.name + $childNameSuffix
        $childId = $resourceId + $childNameSuffix
        $ro = New-Object PSCustomObject -Property @{ name = $childName; id = $childId; resourceGroup = $resource.resourceGroup }
        $childResources.Add($ro) | Out-Null
    
        $childNameSuffix = "/tableServices/default"
        $childName = $resource.name + $childNameSuffix
        $childId = $resourceId + $childNameSuffix
        $ro = New-Object PSCustomObject -Property @{ name = $childName; id = $childId; resourceGroup = $resource.resourceGroup }
        $childResources.Add($ro) | Out-Null
      }
    }

    $resources.AddRange($childResources) | Out-Null
  }

  return $resources
}

function Remove-ResourceGroup()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName
  )

  $rgExists = Test-ResourceGroupExists -rgName $ResourceGroupName

  if ($rgExists)
  {
    Write-Debug -Debug:$true -Message "Delete Resource Group locks for $ResourceGroupName"
    $lockIds = "$(az lock list -g $ResourceGroupName -o tsv --query '[].id')" | Where-Object { $_ }
    foreach ($lockId in $lockIds)
    {
      az lock delete --ids "$lockId"
    }

    Write-Debug -Debug:$true -Message "Delete Resource Group $ResourceGroupName"
    az group delete -n $ResourceGroupName --yes
  }
  else
  {
    Write-Debug -Debug:$true -Message "Resource Group $ResourceGroupName not found"
  }
}

function Test-ResourceExists()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceType,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceName
  )

  Write-Debug -Debug:$true -Message "Test-ResourceExists: SubscriptionId: $SubscriptionId, ResourceGroupName: $ResourceGroupName, ResourceType: $ResourceType, ResourceName: $ResourceName"

  $resourceId = az resource show `
    --subscription $SubscriptionId `
    -g $ResourceGroupName `
    --resource-type $ResourceType `
    -n $ResourceName `
    -o tsv `
    --query 'id' 2>&1

  if (!$?)
  {
    $resourceId = ""
  }

  if ($resourceId)
  {
    $resourceExists = $true
  }
  else
  {
    $resourceExists = $false
  }

  return $resourceExists
}

function Test-ResourceGroupExists()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    [Parameter(Mandatory=$true)]
    [string]
    $ResourceGroupName
  )

  Write-Debug -Debug:$true -Message "Test-ResourceGroupExists: SubscriptionId: $SubscriptionId, ResourceGroupName: $ResourceGroupName"

  $rgExists = [System.Convert]::ToBoolean("$(az group exists --subscription $SubscriptionId -n $ResourceGroupName)")

  return $rgExists
}
