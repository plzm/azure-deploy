# ##################################################
# Script to deploy Azure DevOps project, variable group and variables, service principal, service connections, and import pipelines from GitHub source repository.
# This script is called from AzDevOps-Harness.ps1 but can be adapted to be called from anything that can call PowerShell scripts.
# Further customization is possible by using selected function calls to the functions in AzDevOps-Functions.ps1 in other scripts, pipelines or environments.
# ***** --> Minimal/fastest path: customize the variable values in AzDevOps-Harness.ps1, then run it.
# ##################################################
# PARAMETERS

param
(
  # If not specified, this script will get it from authentication context. This is a GUID and you can get it from az account show -o tsv --query 'tenantId'
  [string] $AzureTenantId = $null,
  # If not specified, this script will get it from authentication context. This is a GUID and you can get it from az account show -o tsv --query 'id'. The Azure service connection will connect to this Azure subscription.
  [string] $AzureSubscriptionId = $null,
  # Azure DevOps organizational URL, like https://dev.azure.com/YOUR_AZURE_DEV_OPS_ORG and replace YOUR_AZURE_DEV_OPS_ORG with your real value.
  [string] $AzDevOpsOrgUrl,
  # The name of the Azure DevOps project to create. If it does not exist, it will be created. If it already exists, the script will deploy into the existing project.
  [string] $AzDevOpsProjectName,
  # Environment to provision. Examples: "e2e", "int", "prod".
  [string] $AzDevOpsEnvironmentName,
  # Service Principal name to create for use with Azure Service Connection. Must be unique in the Azure tenant. There are no naming rules for Service Principals, but a naming convention makes sense for organization/governance. Example name could be "sp-MYORG-MYDEPT" or similar, where MYORG and MYDEPT could be replaced by specific infixes for your organization, department, etc. Keep it simple and clear.
  [string] $ServicePrincipalName,
  # GitHub Personal Access Token for service connection and pipeline imports. Needs admin:repo_hook, repo.*, user.*, and must be SSO-enabled if required by your GitHub org. Manage PATs at https://github.com/settings/tokens
  [string] $GithubPAT,
  # Your individual or organizational GitHub account name, i.e. https://github.com/GITHUB_ACCOUNT_NAME. Just pass the account name, i.e. the real value instead of GITHUB_ACCOUNT_NAME from your GitHub account.
  [string] $GithubAccountName,
  # The repo name in your GitHub account. This must already exist and contain the Azure DevOps YAML pipeline files.
  [string] $GithubRepoName,
  # The branch name in your GitHub repo from which the Azure DevOps pipelines should be imported. Typically "main" but specify for your needs.
  [string] $GithubBranchName,
  # Whether pipelines should skip running immediately after import. Pass $true to skip (NOT run) pipelines immediately.
  [bool] $SkipFirstPipelineRun = $true,
  # Username provisioned in AAD B2C to use for smoke tests
  [string] $AzDevOpsVar1,
  # Hashtable of key-value pairs to add to the created Variable Group as individual Variables
  $AzDevOpsSecrets
)

# ##################################################

# Set Azure CLI to auto install extensions
az config set extension.use_dynamic_install=yes_without_prompt
az config set extension.run_after_dynamic_install=$true

# ##################################################

# Dot-source the functions
. .\AzDevOps-Functions.ps1

# ##################################################
# VARIABLES
# These are based on PARAMETERS and do not need to be explicitly specified by callers

# Get tenant and/or subscription from context if they were not otherwise specified
if (!$AzureTenantId -or !$AzureSubscriptionId) {
  $azureAccount = Get-AzureAccount

  if (!$AzureTenantId) {$AzureTenantId = $azureAccount.tenantId}
  if (!$AzureSubscriptionId) {$AzureSubscriptionId = $azureAccount.id}
}

# GitHub repo URL assembled from passed account name and repo name
[string] $githubRepoUrl = "https://github.com/${GithubAccountName}/${GithubRepoName}"

# One of: "public", "private". Typically use "private" unless you need to make this Azure DevOps project visible outside your organization.
[string] $AzDevOpsProjectVisibility = "private"

# AzDO variable group name
[string] $AzDevOpsVarGrpName = "${AzDevOpsEnvironmentName}-env-vg"

# Service connections to GitHub and Azure
[string] $githubServiceConnectionName = "github-serviceconnection"
[string] $azureServiceConnectionName = "${AzDevOpsEnvironmentName}-serviceconnection"

# AzDO variable groups MUST be created with at least one variable
# We'll pass the smoke test username as it's not secret, and variables passed with variable group creation are stored non-secret
# Have to create variables separately to store as secret
[string] $firstVariableName = "var1"
[string] $firstVariableValue = $AzDevOpsVar1

# ##################################################
# TASKS

Write-Host "Create Service Principal"
$servicePrincipal = New-ServicePrincipal `
  -azureSubscriptionId $AzureSubscriptionId `
  -servicePrincipalName $ServicePrincipalName

Write-Host "Create AzDO Project"
New-AzDevOpsProject `
  -azureSubscriptionId $AzureSubscriptionId `
  -azdoOrgUrl $AzDevOpsOrgUrl `
  -azdoProjectName $AzDevOpsProjectName `
  -azdoProjectVisibility $AzDevOpsProjectVisibility

Write-Host "Create AzDO Variable Group"
$vgId = New-AzDevOpsVariableGroup `
  -azureSubscriptionId $AzureSubscriptionId `
  -azdoOrgUrl $AzDevOpsOrgUrl `
  -azdoProjectName $AzDevOpsProjectName `
  -azdoVariableGroupName $AzDevOpsVarGrpName `
  -variableName $firstVariableName `
  -variableValue $firstVariableValue `
  -allPipelines $true

Write-Host "Create AzDO Variables as Secrets"
$AzDevOpsSecrets.keys | ForEach-Object {
  New-AzDevOpsVariable `
    -azureSubscriptionId $AzureSubscriptionId `
    -azdoOrgUrl $AzDevOpsOrgUrl `
    -azdoProjectName $AzDevOpsProjectName `
    -azdoVariableGroupId $vgId `
    -variableName $_ `
    -variableValue $AzDevOpsSecrets[$_] `
    -secret $true
}


Write-Host "Create GitHub Service Connection in AzDO Project"
$githubServiceConnectionId = New-GithubServiceConnection `
  -azureSubscriptionId $AzureSubscriptionId `
  -azdoOrgUrl $AzDevOpsOrgUrl `
  -azdoProjectName $AzDevOpsProjectName `
  -githubServiceConnectionName $githubServiceConnectionName `
  -githubPat $GithubPAT `
  -githubRepoUrl $githubRepoUrl

Write-Host "Create Azure Service Connection in AzDO Project"
New-AzureServiceConnection `
  -azureTenantId $AzureTenantId `
  -azureSubscriptionId $AzureSubscriptionId `
  -azdoOrgUrl $AzDevOpsOrgUrl `
  -azdoProjectName $AzDevOpsProjectName `
  -azureServiceConnectionName $azureServiceConnectionName `
  -servicePrincipal $servicePrincipal

Write-Host "Get list of AzDO pipeline files in GitHub repo"
$pipelineFiles = Get-PipelineFilesInGithubRepo `
  -githubRepoOwner $GithubAccountName `
  -githubPat $GithubPAT `
  -githubRepoName $GithubRepoName `
  -githubBranch $GithubBranchName `
  -azdoEnvName $AzDevOpsEnvironmentName

Write-Host "Import AzDO pipelines"
Import-Pipelines `
  -azureSubscriptionId $AzureSubscriptionId `
  -azdoOrgUrl $AzDevOpsOrgUrl `
  -azdoProjectName $AzDevOpsProjectName `
  -githubPat $GithubPAT `
  -githubRepoUrl $githubRepoUrl `
  -githubBranch $GithubBranchName `
  -githubServiceConnectionId $githubServiceConnectionId `
  -skipFirstPipelineRun $SkipFirstPipelineRun `
  -pipelineFiles $pipelineFiles
# ##################################################
