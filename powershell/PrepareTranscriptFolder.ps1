<#
.SYNOPSIS
This scripts configures ACL for a "write-only" folder to receive PowerShell
transcript logs.

Original version by Lee Holmes, available here:
https://blogs.msdn.microsoft.com/powershell/2015/06/09/powershell-the-blue-team/

.DESCRIPTION
By default, creates a folder at the root of the system with proper ACL to
receive PowerShell transcript logs. Use the "EnableShare" switch to also
create a network share pointing to that folder. The shared folder permissions
allow access to "Everyone", restrictions are applied with the actual folder
ACL.

The "EnableShare" switch requires running the script on at leat a Windows 8
or 2012 system because of a dependancy on the "SmbShare" module.

.EXAMPLE
.\PrepareTranscriptFolder.ps1 -TranscriptFolder "C:\Logs\PowerShell\Transcripts" -ShareName "transcripts" -EnableShare
#>

param(
    [Parameter(Mandatory=$false)][String]$TranscriptFolder,
    [Parameter(Mandatory=$false)][String]$ShareName,
    [switch]$EnableShare
)

if (-not($TranscriptFolder)) {
    $TranscriptFolder = "C:\PsTranscripts"
}
if (-not($ShareName)) {
    $ShareName = "PsTranscripts"
}

New-Item -ItemType Directory -Force -Path $TranscriptFolder -ErrorAction Stop | Out-Null

## Kill all inherited permissions
$acl = Get-Acl $TranscriptFolder
$acl.SetAccessRuleProtection($true, $false)

## Grant Administrators full control
$adminsSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
$administrators = $adminsSID.Translate([System.Security.Principal.NTAccount]).Value
$permission = $administrators,"FullControl","ObjectInherit,ContainerInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Grant everyone else Write and ReadAttributes. This prevents users from listing
## transcripts from other machines on the domain.
$everyoneSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-1-0")
$everyone = $everyoneSID.Translate([System.Security.Principal.NTAccount]).Value
$permission = $everyone,"Write,ReadAttributes","ObjectInherit,ContainerInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Deny "Creator Owner" everything. This prevents users from
## viewing the content of previously written files.
$creatorOwnerSID = New-Object System.Security.Principal.SecurityIdentifier("S-1-3-0")
$creatorOwner = $creatorOwnerSID.Translate([System.Security.Principal.NTAccount]).Value
$permission = $creatorOwner,"FullControl","ObjectInherit,ContainerInherit","InheritOnly","Deny"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.AddAccessRule($accessRule)

## Set the ACL
$acl | Set-Acl $TranscriptFolder -ErrorAction Stop
Write-Verbose "Succesfully set ACL on $TranscriptFolder"

if ($EnableShare) {
    New-SmbShare -Name $ShareName -Path $TranscriptFolder -ChangeAccess $everyone -ErrorAction Stop | Out-Null
    Write-Verbose "Successfully enabled share $ShareName"
}