#Requires -Version 7.0
#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Applications
<#
.SYNOPSIS
  Enables Microsoft Entra authentication for RDP on the service principals used by
  Azure Virtual Desktop single sign-on. Run once per tenant.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $TenantId
)

$ErrorActionPreference = 'Stop'

Connect-MgGraph -TenantId $TenantId -Scopes 'Application.Read.All', 'Application-RemoteDesktopConfig.ReadWrite.All' -NoWelcome

$applications = [ordered]@{
    'Microsoft Remote Desktop' = 'a4a365df-50f1-4397-bc59-1a1564b8bb9c'
    'Windows Cloud Login'      = '270efc09-cd0d-444b-a71f-39af4910ec45'
}

foreach ($name in $applications.Keys) {
    $appId = $applications[$name]
    $servicePrincipal = Get-MgServicePrincipal -Filter "appId eq '$appId'"

    if (-not $servicePrincipal) {
        throw "Service principal '$name' ($appId) not found. Create it with: Connect-MgGraph -Scopes Application.ReadWrite.All; New-MgServicePrincipal -AppId $appId"
    }

    $config = Get-MgServicePrincipalRemoteDesktopSecurityConfiguration -ServicePrincipalId $servicePrincipal.Id -ErrorAction SilentlyContinue

    if ($config.IsRemoteDesktopProtocolEnabled -eq $true) {
        Write-Host "Already enabled: $name"
    }
    else {
        Update-MgServicePrincipalRemoteDesktopSecurityConfiguration -ServicePrincipalId $servicePrincipal.Id -IsRemoteDesktopProtocolEnabled
        Write-Host "Enabled Entra RDP authentication: $name"
    }
}

Disconnect-MgGraph | Out-Null