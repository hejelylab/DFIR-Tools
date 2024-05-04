<#
.SYNOPSIS


--------------
## DESCRIPTION
Simple PowerShell script that uses the most needed options in Hayabusa to hunt in EventLogs directory.
The objective is to have the various options executed using the script directly.
Options are: 
	- Computer Metrics to identify if there are unknown devices appearing in the eventlogs
	- EventID Metrics to have a glimpse about the Event IDs in the eventlogs
	- Successful and Failed Logon Summary
	- Using Sigma and Hayabusa rules against the eventlogs
	- Using string search against the eventlogs, more string can be added by -k "keyword"

hayabusa folder is expected to be in the same path as EventLogsAnalyzer.ps1
--------------
## EXAMPLE
Example 1: .\EventLogsAnalyzer.ps1 -CasePath "D:\CaseName" -Hostname Hostname1 -ImageMountedDrive F -DefaultANDSigmaScan
Example 2: .\EventLogsAnalyzer.ps1 -CasePath "D:\CaseName" -Hostname Hostname1 -ImageMountedDrive F -StringSearch
Example 3: .\EventLogsAnalyzer.ps1 -CasePath "D:\CaseName" -Hostname Hostname1 -ImageMountedDrive F -DefaultANDSigmaScan -StringSearch
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$CasePath,

    [Parameter(Mandatory=$true)]
    [string]$Hostname,

    [Parameter(Mandatory=$true)]
    [string]$ImageMountedDrive,
	
	[Parameter()]
    [switch]$DefaultANDSigmaScan,
	
	[Parameter()]
    [switch]$StringSearch
)
if($help) {
    Get-Help $MyInvocation.MyCommand.Definition
    exit
}


function DefaultANDSigmaScan {	
	.\hayabusa*.exe computer-metrics -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_computer_metrics.csv
	.\hayabusa*.exe eid-metrics -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_eid_metrics.csv
	.\hayabusa*.exe logon-summary -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_logon_summary.csv

	.\hayabusa*.exe csv-timeline -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_Results.csv --no-wizard
	.\hayabusa*.exe csv-timeline --EID-filter -d "$ImageMountedDrive`:\Windows\System32\winevt\logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_EID_Filters.csv --no-wizard --remove-duplicate-data	
}

function StringSearch {	
	.\hayabusa*.exe search --ignore-case -k "DownloadString" -k "DownloadFile" -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_StringSearch_keywords.csv
	.\hayabusa*.exe search --ignore-case -k ".zip" -k ".ps1" -k ".rar" -k ".7z" -d "$ImageMountedDrive`:\Windows\System32\winevt\Logs" -o $CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_HayabusaScan_StringSearch_extensions.csv
}

$startTime = Get-Date
Write-Host "Start of Execution at: $startTime" -ForegroundColor Yellow

Set-Location .\hayabusa

$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$CaseName = (Split-Path $CasePath -Leaf)

if(!(Test-Path -PathType container $CasePath\$Hostname\ParsedEvidence\ScanResults)){
	New-Item -ItemType Directory -Path $CasePath\$Hostname\ParsedEvidence\ScanResults > $null
}
	
if($DefaultANDSigmaScan){
	$DefaultANDSigmaScanScanStartTime = Get-Date
	Write-Host "Start of Default and Sigma Scan at: $DefaultANDSigmaScanScanStartTime" -ForegroundColor Cyan
	
	DefaultANDSigmaScan
	
	$DefaultANDSigmaScanScanEndTime = Get-Date
	Write-Host "End of Default and Sigma Scan at: $DefaultANDSigmaScanScanEndTime" -ForegroundColor Cyan
	$DefaultANDSigmaScanScanTime = $DefaultANDSigmaScanEndTime - $DefaultANDSigmaScanStartTime
	Write-Host "Default and Sigma Scan executed in $($DefaultANDSigmaScanScanTime.TotalSeconds) seconds." -ForegroundColor Cyan
}

if($StringSearch){
	$StringSearchStartTime = Get-Date
	Write-Host "Start of Eventlogs String Search at: $StringSearchStartTime" -ForegroundColor Cyan
	
	StringSearch
	
	$StringSearchEndTime = Get-Date
	Write-Host "End of Eventlogs String Search at: $StringSearchEndTime" -ForegroundColor Cyan
	$StringSearchTime = $StringSearchEndTime - $StringSearchStartTime
	Write-Host "Eventlogs String Search executed in $($StringSearchTime.TotalSeconds) seconds." -ForegroundColor Cyan
}

$endTime = Get-Date
Write-Host "End of Execution at: $endTime" -ForegroundColor Yellow