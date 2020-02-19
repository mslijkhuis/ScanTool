# -----------------------------------------------------------------------------------------------------------------
# Written by: Ruerd Jan van der Wal
# Date: 19-02-2020
# Platform: Tested on Windows 7 and Windows 10
# ToDo: Remove Dutch words/descriptions.
# -----------------------------------------------------------------------------------------------------------------

$outFilePath = "c:\temp\PowerShell\" # Change this to any path. UNC path have not been tested.
$logFile = $outFilePath+"ScanLog.txt"
$drives = Get-WmiObject -Query "Select * from Win32_logicaldisk where DriveType = 3"
$driveCount = 0
$fileSize = 50000000
$computerName = hostname
$scanFileExtension = ".csv"
$leeftijdBestandDagen = 75

# Powershell can not count the value of 1. Therefor, a small if the make sure the numbers match.
if (($drives.Count) -le 1) {
    $driveCount = 1
} else {
    $driveCount = ($drives.count)
}

Add-Content -Path $logFile -value "----------------------------------------------------------------------------------"
Add-Content -Path $logFile -Value ((Get-Date).ToString() + " Scan gestart op " + $computerName)
Add-Content -Path $logFile -Value ("Er zijn " + $driveCount + " lokale drives gevonden op " + $computerName)

foreach ($drive in $drives) {  
    $driveLetter = $drive.DeviceID+"\"
    $scanFile = $computerName + "_" + $drive.DeviceID.Substring(0,1) + "drive" + $scanFileExtension

    if (Test-Path ($outFilePath+$scanFile)) {
        $leeftijdBestand = Get-ChildItem ($outFilePath + $scanFile) | New-TimeSpan

	if ($leeftijdBestand.TotalSeconds -gt $leeftijdBestandDagen) {
	    Remove-Item -Path ($outFilePath + $scanFile) -Force
	    Add-Content -Path $logFile -Value ("Logboek van " + $computerName + " " + $driveLetter + " is verwijderd wegens " + $leeftijdBestandDagen + " dagen oud.")
	    Get-ChildItem -Path $driveLetter -Recurse -Force -ErrorAction SilentlyContinue | Where {$_.Length -gt $fileSize} | Select-Object Mode,Name,CreationTime,DirectoryName,Length | Export-Csv -Path ($outFilePath + $scanFile) -NoTypeInformation
	    Add-Content -path $logFile -value ($computerName + " " + $driveLetter + " is gescanned. " + $outFile + " " + (Get-Date).ToString())
	} else {
	    Add-Content -Path $logFile -Value ("Scannen van " + $computerName + " " + $driveLetter + " is overgeslagen wegens recent log.")
	}
    } else {
	Get-ChildItem -Path $driveLetter -Recurse -Force -ErrorAction SilentlyContinue | Where {$_.Length -gt $fileSize} | Select-Object Mode,Name,CreationTime,DirectoryName,Length | Export-Csv -Path ($outFilePath + $scanFile) -NoTypeInformation
	Add-Content -path $logFile -value ($computerName + " " + $driveLetter + " is gescanned. " + $outFile + " " + (Get-Date).ToString())
    }
}

Add-Content -Path $logFile -Value ((Get-Date).ToString() + " Scan afgerond op " + $computerName)
