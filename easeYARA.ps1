<#
.SYNOPSIS


--------------
## DESCRIPTION
Simplified PowerShell Script implementation of easeYARA C# GUI Desktop application that you can get its release from: https://github.com/hejelylab/easeYARA/releases/tag/v0.0.2
- Loki folder is expected to be in the same path as easeYARA.ps1
--------------
## EXAMPLE
Example 1: .\easeYARA.ps1 -CasePath "D:\CaseName" -Hostname Hostname1 -ImageMountedDrive F -YARAScanner Loki
Example 2: .\easeYARA.ps1 -CasePath "D:\CaseName" -Hostname Hostname1 -ImageMountedDrive F -YARAScanner Loki -TargetedDirectories
#>
param (
    [Parameter(Mandatory=$true)]
    [string]$CasePath,

    [Parameter(Mandatory=$true)]
    [string]$Hostname,

    [Parameter(Mandatory=$true)]
    [string]$ImageMountedDrive,

	[Parameter()]
	[ArgumentCompleter({
		$YARAScanner = "VirusTotalYARA", "Loki"
		$YARAScanner | ForEach-Object {
			[System.Management.Automation.CompletionResult]::new($_,$_,'ParameterValue',$_)
		}
	})]
	[string[]]$YARAScanner,	
	
	[Parameter()]
    [switch]$TargetedDirectories
)
if($help) {
    Get-Help $MyInvocation.MyCommand.Definition
    exit
}


function YARAScan {
	$YARAScanStartTime = Get-Date
	Write-Host "Start of YARA Scan at: $YARAScanStartTime" -ForegroundColor Cyan
	
	if(!(Test-Path -PathType container $CasePath\$Hostname\ParsedEvidence\ScanResults)){
		New-Item -ItemType Directory -Path $CasePath\$Hostname\ParsedEvidence\ScanResults > $null
	}
	if($YARAScanner -eq "VirusTotalYARA"){
		### To be added ...
		
	}
	if($YARAScanner -eq "Loki"){
		if($TargetedDirectories){
			foreach($tdArray1 in $tdArray){
				$tdArray2  = $ImageMountedDrive + $tdArray1
				.\loki\loki.exe -p $tdArray2  -l "$CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_LokiScan_Results_$($tdArray.IndexOf($tdArray1) + 1).csv" --noprocscan --pesieveshellc --rootkit --intense --allreasons --csv
			}
		}
		else{
			.\loki\loki.exe -p  $ImageMountedDrive`:\ -l "$CasePath\$Hostname\ParsedEvidence\ScanResults\$($CaseName)_$($Hostname)_LokiScan_Results.csv" --noprocscan --pesieveshellc --rootkit --intense --allreasons --csv
		}
		
	}

	$YARAScanEndTime = Get-Date
	Write-Host "End of YARA Scan at: $YARAScanEndTime" -ForegroundColor Cyan
	
	$YARAScanTime = $YARAScanEndTime - $YARAScanStartTime
	Write-Host "YARA Scan executed in $($YARAScanTime.TotalSeconds) seconds." -ForegroundColor Cyan
}

$startTime = Get-Date
Write-Host "Start of Execution at: $startTime" -ForegroundColor Yellow

$ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$CaseName = (Split-Path $CasePath -Leaf)
$tdArray = @(":\Users\Public",":\ProgramData",":\inetpub\wwwroot\aspnet_client",":\Program Files\Microsoft\Exchange Server",":\Windows\Temp",":\Temp",":\Program Files",":\Program Files (x86)",":\Windows\System32")

YARAScan

$endTime = Get-Date
Write-Host "End of Execution at: $endTime" -ForegroundColor Yellow