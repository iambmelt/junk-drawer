$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$registryValue = "Hidden"

$previousValue = (Get-ItemProperty -Path $registryPath).$registryValue

while ($true) {
    $currentValue = (Get-ItemProperty -Path $registryPath).$registryValue
    
    if ($previousValue -ne $currentValue) {
        $message = "Registry value $registryValue changed from $previousValue to $currentValue"
        Write-Host $message
        # Add your notification code here, such as sending an email or writing to a log file
    }
    
    $previousValue = $currentValue
    
    # Wait for 1 minute before checking again
    Start-Sleep -Seconds 60
}
