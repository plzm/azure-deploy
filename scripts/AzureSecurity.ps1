function Deploy-RoleAssignment()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $RoleDefinitionId,
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId,
    [Parameter(Mandatory = $false)]
    [string]
    $PrincipalType = "ServicePrincipal",
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceType,
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceName
  )

  Write-Debug -Debug:$true -Message "Deploy Role Assignment: RoleDefinitionId=$RoleDefinitionId, PrincipalId=$PrincipalId, PrincipalType=$PrincipalType, ResourceGroupName=$ResourceGroupName, ResourceType=$ResourceType, ResourceName=$ResourceName"

  $deploymentName = "$Location-$ResourceName-$RoleDefinitionId"

  $output = az deployment sub create --verbose `
    -n "$deploymentName" `
    --location="$Location" `
    --template-uri "$TemplateUri" `
    --parameters `
    roleDefinitionId="$RoleDefinitionId" `
    principalId="$PrincipalId" `
    principalType="$PrincipalType" `
    resourceGroupName="$ResourceGroupName" `
    resourceType="$ResourceType" `
    resourceName="$ResourceName" `
    | ConvertFrom-Json

  return $output
}

function Deploy-RoleAssignmentRg()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $RoleDefinitionId,
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId,
    [Parameter(Mandatory = $false)]
    [string]
    $PrincipalType = "ServicePrincipal",
    [Parameter(Mandatory = $true)]
    [string]
    $ResourceGroupName
  )

  Write-Debug -Debug:$true -Message "Deploy RG Role Assignment: RoleDefinitionId=$RoleDefinitionId, PrincipalId=$PrincipalId, PrincipalType=$PrincipalType, ResourceGroupName=$ResourceGroupName"

  $deploymentName = "$Location-$ResourceGroupName-$RoleDefinitionId"

  $output = az deployment sub create --verbose `
    -n "$deploymentName" `
    --location="$Location" `
    --template-uri "$TemplateUri" `
    --parameters `
    roleDefinitionId="$RoleDefinitionId" `
    principalId="$PrincipalId" `
    principalType="$PrincipalType" `
    resourceGroupName="$ResourceGroupName" `
    | ConvertFrom-Json

  return $output
}

function Deploy-RoleAssignmentSub()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $Location,
    [Parameter(Mandatory = $true)]
    [string]
    $TemplateUri,
    [Parameter(Mandatory = $true)]
    [string]
    $RoleDefinitionId,
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId,
    [Parameter(Mandatory = $false)]
    [string]
    $PrincipalType = "ServicePrincipal"
  )

  Write-Debug -Debug:$true -Message "Deploy Sub Role Assignment: RoleDefinitionId=$RoleDefinitionId, PrincipalId=$PrincipalId, PrincipalType=$PrincipalType"

  $deploymentName = "$Location-$RoleDefinitionId"

  $output = az deployment sub create --verbose `
    -n "$deploymentName" `
    --location="$Location" `
    --template-uri "$TemplateUri" `
    --parameters `
    roleDefinitionId="$RoleDefinitionId" `
    principalId="$PrincipalId" `
    principalType="$PrincipalType" `
    | ConvertFrom-Json

  return $output
}

function Deploy-UserAssignedIdentity()
{
  <#
    .SYNOPSIS
    This command deploys an Azure User Assigned Identity.
    .DESCRIPTION
    This command deploys an Azure User Assigned Identity.
    .PARAMETER SubscriptionId
    The Azure subscription ID
    .PARAMETER Location
    The Azure region
    .PARAMETER ResourceGroupName
    The Resource Group name
    .PARAMETER TemplateUri
    The ARM template URI
    .PARAMETER TenantId
    The Azure tenant ID
    .PARAMETER UAIName
    The User Assigned Identity name
    .PARAMETER Tags
    Tags
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./Deploy-UAI.ps1
    PS> Deploy-UAI -SubscriptionID "MyAzureSubscriptionId" -Location "westus" -ResourceGroupName "MyResourceGroupName" -TemplateUri "MyARMTemplateURI" -TenantId "MyTenantId" -UAIName "MyUAIName" -Tags "MyTags"
    .LINK
    None
  #>

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
    $TenantId,
    [Parameter(Mandatory = $true)]
    [string]
    $UAIName,
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Deploy UAI $UAIName"

  $tagsForTemplate = Get-TagsForArmTemplate -Tags $Tags

  $output = az deployment group create --verbose `
    --subscription "$SubscriptionId" `
    -n "$UAIName" `
    -g "$ResourceGroupName" `
    --template-uri "$TemplateUri" `
    --parameters `
    location="$Location" `
    tenantId="$TenantId" `
    identityName="$UAIName" `
    tags="$tagsForTemplate" `
    | ConvertFrom-Json

  return $output
}

function New-ServicePrincipal()
{
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionName,
    [Parameter(Mandatory = $true)]
    [string]
    $ServicePrincipalName,
    [Parameter()]
    [string]
    $RoleName = "Owner"
  )

  $subscriptionId = "$(az account show -s $SubscriptionName -o tsv --query 'id')"

  az ad sp create-for-rbac --name "$ServicePrincipalName" --role "$RoleName" --scopes "/subscriptions/$subscriptionId" --verbose --sdk-auth
}

function Remove-RoleAssignments()
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
    [Parameter(Mandatory = $true)]
    [string]
    $PrincipalId
  )

  if ($ResourceGroupName)
  {
    $Scope = "/subscriptions/" + $SubscriptionId + "/resourceGroups/" + $ResourceGroupName
  }
  else
  {
    $Scope = "/subscriptions/" + $SubscriptionId
  }

  # Have to do it this way because Powershell will make a one-item result into a string, not an array
  [System.Collections.ArrayList]$assignments = @()
  $a = "$(az role assignment list --scope $Scope --assignee $PrincipalId --query '[].id')" | ConvertFrom-Json
  $assignments.Add($a)
  # Have to trim out null items, which Powershell creates when adding arrays
  $assignments = $assignments.Where({ $null -ne $_ })

  if ($assignments.Count -eq 0)
  {
    Write-Debug -Debug:$true -Message "No role assignments found for $PrincipalId"
  }
  else
  {
    foreach ($assignment in $assignments)
    {
      Write-Debug -Debug:$true -Message "Delete Role Assignment $assignment"
      az role assignment delete --verbose --ids $assignment
    }
  }
}
