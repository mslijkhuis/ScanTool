# -----------------------------------------------------------------------------------------------------------------
# Geschreven door: Ruerd Jan van der Wal
# Gemaakt op: 19-02-2020
# Getest op Windows 7 Pro en Windows 10 Pro
# Dit script zoekt alle lokale drives op en gaat deze 1 voor 1 scannen. 
# Middels de variabele $fileSize kan de minimale bestandsomvang ingesteld worden in bytes.
# Bestanden kleiner dan die waarde worden uitgesloten.
# Middels de variabele $leeftijdBestandDagen kan het herscannen beperkt worden.
# Indien de scanlog van de PC ouder is dan die waarde, zal het opnieuw gescanned worden. Anders gebeurt er niets.
# -----------------------------------------------------------------------------------------------------------------

$outFilePath = "c:\temp\PowerShell\"
$logFile = $outFilePath+"ScanLog.txt"
$drives = Get-WmiObject -Query "Select * from Win32_logicaldisk where DriveType = 3"
$driveCount = 0
$fileSize = 50000000
$computerName = hostname
$scanFileExtension = ".csv"
$leeftijdBestandDagen = 75

# Powershell maakt een foutje bij 1 lokale drive, dan is de waarde null. 
# Middels deze if klopt de waarde tenminste.
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