function Get-ConfigFromFile()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $ConfigFilePath
  )

  Write-Debug -Debug:$debug -Message ("Get-ConfigConstants: ConfigFilePath: " + "$ConfigFilePath")

  Get-Content -Path "$ConfigFilePath" | ConvertFrom-Json
}

function Get-EnvVars()
{
  Write-Debug -Debug:$debug -Message ("Get-EnvVars")

  Get-ChildItem env:
}

function Get-Timestamp()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [bool]
    $MakeStringSafe=$false
  )

  $result = (Get-Date -AsUTC -format s) + "Z"

  if ($MakeStringSafe)
  {
    $result = $result.Replace(":", "-")
  }

  return $result
}

function Get-TimestampForObjectNaming()
{
  ((Get-Timestamp).Replace(":", "").Replace("-", "")).ToLower()
}

function New-RandomString
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false)]
    [Int]
    $Length = 10
  )

  return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))
}

function Set-EnvVarTags()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [object]
    $ConfigConstants = $null,
    [Parameter(Mandatory = $false)]
    [object]
    $ConfigMain = $null
  )

  Write-Debug -Debug:$debug -Message ("Set-EnvVarTags")

  $tagsForAzureCli = @()
  $tag1 = "foo=bar"

  #if ($ConfigConstants)
  #{
  #  $tag2 = "baz=bam"

  #  $tagsForAzureCli = @($tag1, $tag2)
  #}
  #else
  #{
  $tagsForAzureCli = @($tag1)
  #}

  $tagsObject = @{}
  $tagsObject['foo'] = "bar"

  #if ($ConfigConstants)
  #{
  #  $tagsObject['baz'] ="bam"
  #}

  # The following manipulations are needed to get through separate un-escaping by Powershell AND by Azure CLI, 
  # and to get CLI to correctly see the tags as a JSON string passed into ARM templates as an object type.
  $tagsForArm = ConvertTo-Json -InputObject $tagsObject -Compress
  $tagsForArm = $tagsForArm.Replace('"', '''')
  $tagsForArm = "`"$tagsForArm`""

  # Set the env vars
  # Tags for straight CLI commands
  Set-EnvVar2 -VarName "AA_TAGS_FOR_CLI" -VarValue "$tagsForAzureCli"
  # Tags for ARM template tags parameter - do not quote the variable for this, breaks ARM template tags
  Set-EnvVar2 -VarName "AA_TAGS_FOR_ARM" -VarValue $tagsForArm
}

function Set-EnvVar2
{
  <#
    .SYNOPSIS
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .DESCRIPTION
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .PARAMETER VarName
    The environment variable name.
    .PARAMETER VarValue
    The environment variable value.
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./scripts/infra/Utility.ps1
    PS> Set-EnvVar2 -VarName "FOO" -VarValue "BAR"
    .LINK
    None
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $VarName,
    [Parameter(Mandatory = $true)]
    [string]
    $VarValue
  )

  Write-Debug -Debug:$debug -Message ("Set-EnvVar2: VarName: " + "$VarName" + ", VarValue: " + "$VarValue")

  if ($env:GITHUB_ENV)
  {
    #Write-Host "GH"
    Write-Output "$VarName=$VarValue" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
  }
  else
  {
    #Write-Host "local"
    $cmd = "$" + "env:" + "$VarName='$VarValue'"
    #$cmd
    Invoke-Expression $cmd
  }
}

function Set-EnvVar1()
{
  <#
    .SYNOPSIS
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .DESCRIPTION
    This command sets an environment variable. It detects if the runtime context is GitHub Actions and if so, sets it correctly for GHA runners.
    .PARAMETER VarPair
    The environment variable name and value as VAR_NAME=VAR_VALUE
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS> . ./scripts/infra/Utility.ps1
    PS> Set-EnvVar1 -VarPair "FOO=BAR"
    .LINK
    None
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $true)]
    [string]
    $VarPair
  )

  Write-Debug -Debug:$debug -Message ("Set-EnvVar1: VarPair: " + "$VarPair")

  if ($VarPair -like "*=*")
  {
    $arr = $VarPair -split "="

    if ($arr.Count -eq 2)
    {
      Set-EnvVar2 -VarName $arr[0] -VarValue $arr[1]
    }
    else
    {
      Write-Host "You must pass a VarValue param like FOO=BAR, with a variable name separated from variable value by an equals sign. No change made."
    }
  }
  else
  {
    Write-Host "You must pass a VarValue param like FOO=BAR, with a variable name separated from variable value by an equals sign. No change made."
  }
}