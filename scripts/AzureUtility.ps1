function Get-TagsForArmTemplate()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Get-TagsForArmTemplate: $Tags"

  $tagsObject = @{}

  if ($Tags)
  {
    Write-Debug -Debug:$true -Message "Tags: $Tags"

    $tagKVPairs = $Tags.Split(",")

    foreach ($tagKVPair in $tagKVPairs)
    {
      $tagKVArray = $tagKVPair.Split("=")
      $tagsObject[$tagKVArray[0]] = $tagKVArray[1]
    }

    $tagsForArm = ConvertTo-Json -InputObject $tagsObject -Compress
    $tagsForArm = $tagsForArm.Replace('"', '''')
    $tagsForArm = "`"$tagsForArm`""

    $result = ConvertFrom-Json -InputObject $tagsForArm
  }
  else
  {
    Write-Debug -Debug:$true -Message "Tags: Null/Empty"

    $result = "{}"
  }

  return $result
}

function Get-TagsForAzureCli()
{
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory = $false)]
    [object]
    $Tags = $null
  )

  Write-Debug -Debug:$true -Message "Get-TagsForAzureCli: $Tags"

  # Declare an ArrayList
  $tagsArrayList = New-Object System.Collections.ArrayList

  # Split the inbound tags, we assume it's in format of foo=bar,baz=bam
  $tagKVPairs = $Tags.Split(",")

  foreach ($tagKVPair in $tagKVPairs)
  {
    $tagsArrayList.Add($tagKVPair) | Out-Null
  }

  return $tagsArrayList.ToArray()
}

function Remove-AzPackages()
{
  Get-Package | Where-Object { $_.Name -like 'Az*' } | ForEach-Object { Uninstall-Package -Name $_.Name -AllVersions }
}
