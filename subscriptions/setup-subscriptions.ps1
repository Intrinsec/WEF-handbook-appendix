<#
.SYNOPSIS
This script setups subscriptions to target specific groups and/or machines.

.DESCRIPTION
The script uses the template files located in the 'subscription_templates'
subfolder and creates subscriptions with the groups and/or machines defined in
the input files "TargetGroupsFile" and "TargetMachinesFile".
The optional "TemplatesFilesPath" argument can be used to specify a custom
path to load templates, e.g. for subscriptions that will use different target
groups/machines.
The "Import" switch requires local Administrator privileges to enable said
subscriptions.

.EXAMPLE
.\setup-subscriptions.ps1 -TargetGroupsFiles .\sub-groups.txt -TemplatesFilesPath .\subscription_templates-2_month_history -Import
#>

#Requires -Modules ActiveDirectory

param(
    [Parameter(Mandatory=$false)][String]$TargetGroupsFile,
    [Parameter(Mandatory=$false)][String]$TargetMachinesFile,
    [Parameter(Mandatory=$false)][String]$TemplatesFilesPath,
    [switch]$Import
)

Import-Module ActiveDirectory -Cmdlet Get-ADGroup, Get-ADComputer

function Build-SDDL-List
{
    param(
    [String]$Type,
    [String]$TargetsFile,
    [ref]$Descriptors
    )
    
    $Targets = Get-Content $TargetsFile -ErrorAction Stop
    foreach($Target in $Targets) {
        $SidList = @()
        switch ($Type)
        {
            "Group" {$Sid = (Get-ADGroup -Identity "$Target" -ErrorAction Stop | Select -Expand SID).Value}
            "Computer" {$Sid = (Get-ADComputer -Identity "$Target" -ErrorAction Stop | Select -Expand SID).Value}
        }
        if ($Sid -ne $null) {
            $SidList += "(A;;GA;;;" + $Sid + ")"
            $Sid = $null
            Write-Verbose "Added $Target"
        }
        $Descriptors.value += $SidList -join ""
    }
}

$CurrentPath = Split-Path ((Get-Variable MyInvocation -Scope 0).Value).MyCommand.Path
if (-not($TemplatesFilesPath)) {
    $TemplatesFilesPath = "$CurrentPath\subscription_templates"
}
$SubscriptionFilesPath = New-Item -ItemType Directory -Force -Path "$CurrentPath\subscription_files" -ErrorAction stop
$TargetDescriptors = "O:NSG:BAD:P"

if (-not($TargetGroupsFile) -and -not($TargetMachinesFile)) {
    Write-Output "Missing parameter (TargetGroupsFile and/or TargetMachinesFile)."
    Exit 1
}
if ($TargetGroupsFile) {
    Build-SDDL-List -Type "Group" -TargetsFile $TargetGroupsFile -Descriptors ([ref]$TargetDescriptors)
}
if ($TargetMachinesFile) {
    Build-SDDL-List -Type "Computer" -TargetsFile $TargetMachinesFile -Descriptors ([ref]$TargetDescriptors)
}

$TargetDescriptors += "S:"

Get-ChildItem "$TemplatesFilesPath" -Filter "*.xml" -ErrorAction stop | %{
    (Get-Content $_.FullName | out-string).Replace('FIXME_SOURCES', $TargetDescriptors) | Set-Content "$SubscriptionFilesPath\$_"
}

if ($Import.IsPresent -eq $true) {
    Get-ChildItem "$SubscriptionFilesPath" -Filter "*.xml" | %{
        wecutil cs $_.FullName
        Write-Verbose "Enabled subscription $_"
    }
}