<#
.SYNOPSIS
	Modify the OneGet aka PackageManagement.nupkg Repositories variable.
.DESCRIPTION
	Set-RepositoryTrust allows you to add or remove Repositories to your Nuget PATH variable with logic that prevents duplicates.
.PARAMETER AddRepo
    A path that you wish to add. Can be specified with or without a trailing slash.
.PARAMETER RemoveRepo
    A path that you wish to remove. Can be specified with or without a trailing slash.
.PARAMETER Scope
	The scope of the variable to edit. Either Process, User, or Machine.

    If you specify Machine, you must be running as administrator. or using Gsudo
.EXAMPLE
	Set-RepositoryTrust -Addrepo PSgallery 
  Set-RepositoryTrust -RemoveRepo PSgallery

	Set-RepositoryTrust -Addrepo Chocolatey 
  Set-RepositoryTrust -RemoveRepo Chocolatey
    This will add the C:\tmp\bin path and remove the C:\path\java path. The Scope will be set to Process, which is the default.
.INPUTS
	0
.OUTPUTS
	0
.NOTES
	Author: PhilipProchazka
  Created for: Storing Rest API links
.LINK
	
#>#region PSgallery Repository

Get-PSRepository

Function Set-RepositoryTrust {
  param (
      [string]$AddRepo,
      [string]$RemoveRepo,
      [ValidateSet('Process', 'User', 'Machine')]
      [string]$Scope = 'Process'
  ) $regexPaths = @()
  if ($PSBoundParameters.Keys -contains 'AddRepo') {
      $regexPaths += [regex]::Escape($AddRepo)
  } 
  if ($PSBoundParameters.Keys -contains 'RemoveRepo') {
    $regexPaths += [regex]::Escape($RemoveRepo)
}
  'PowershellGet'= 
  param(

  [string]$Location = "https://www.powershellgallery.com/api/v2"
  [string]$Name = "PowershellGet"
  [string]$ProviderName = "PSGallery"
  ),
'Nuget'
param(

  [string]$Location = "https://api.nuget.org/v3/index.json"
  [string]$Name = "Nuget.org"
  [string]$ProviderName = "Nuget"
),

'ChocolateyGet'
param(

  [string]$Location = "https://community.chocolatey.org/api/v2"
  [string]$Name = "ChocolateyGet"
  [string]$ProviderName = "PowerShellGet"
),

Register-PackageSource -Name $Name -Location $Location –ProviderName $ProviderName -Trusted

Register-PackageSource -Name $Name -Location "http://www.nuget.org/api/v2" –ProviderName  $ProviderName  -Trusted

Register-PackageSource -Name ChocolateyGet -Location "https://community.chocolatey.org/api/v2/" –ProviderName PowerShellGet -Trusted
