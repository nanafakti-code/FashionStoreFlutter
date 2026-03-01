$scheme = "fashionstore"
$description = "URL:FashionStore Protocol"
$exePath = "$PSScriptRoot\runner\Debug\fashion_store_flutter.exe" # Adjust this if Release or different path

# Check if the exe exists in Debug, if not try Release, if not warn
if (-not (Test-Path $exePath)) {
    $exePath = "$PSScriptRoot\runner\Release\fashion_store_flutter.exe"
}
if (-not (Test-Path $exePath)) {
    Write-Warning "Executable not found at standard paths. Please build the app first (flutter running windows)."
    # We'll assume standard path for now or use the current directory logic if needed, 
    # but strictly speaking we need the absolute path to the .exe that flutter run builds.
    # For 'flutter run', it's often in build\windows\x64\runner\Debug\fashion_store_flutter.exe
    # The script is in windows/ folder.
    $exePath = "$PSScriptRoot\..\build\windows\x64\runner\Debug\fashion_store_flutter.exe"
}

$exePath = [System.IO.Path]::GetFullPath($exePath)

Write-Host "Registering '$scheme' scheme for: $exePath"

$registryPath = "HKCU:\Software\Classes\$scheme"

# Create the key
New-Item -Path $registryPath -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "URL Protocol" -Value "" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $registryPath -Name "(Default)" -Value $description -PropertyType String -Force | Out-Null

# Create DefaultIcon
$iconPath = "$registryPath\DefaultIcon"
New-Item -Path $iconPath -Force | Out-Null
New-ItemProperty -Path $iconPath -Name "(Default)" -Value "$exePath,1" -PropertyType String -Force | Out-Null

# Create shell\open\command
$commandPath = "$registryPath\shell\open\command"
New-Item -Path $commandPath -Force | Out-Null
New-ItemProperty -Path $commandPath -Name "(Default)" -Value "`"$exePath`" `"%1`"" -PropertyType String -Force | Out-Null

Write-Host "Registration complete. You can test it by opening $scheme://test in your browser."
