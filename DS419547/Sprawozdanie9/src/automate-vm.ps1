$workDir = "C:\Users\Admin\Desktop\auto"
$vmName = "Fedora44-Auto-DS419547"
$vhdPath = "$workDir\$vmName.vhdx"

$isoOriginalName = "Fedora-Server-netinst-x86_64-44-1.7.iso"
$ksIsoName = "config.iso"
$grubCfgName = "grub.cfg"
$isoCustomName = "Fedora-Server-Automated.iso"

Write-Host "--- Start w $workDir ---" -ForegroundColor Cyan

Write-Host "Przebudowa obrazu ISO..."
if (Test-Path "$workDir\$isoCustomName") { 
    Write-Host "Usuwanie starego obrazu $isoCustomName..."
    Remove-Item "$workDir\$isoCustomName" -Force 
}

$wslPath = "/mnt/c/Users/Admin/Desktop/auto"
$wslCmd = "cd $wslPath && xorriso -indev $isoOriginalName -outdev $isoCustomName -boot_image any replay -map $grubCfgName /EFI/BOOT/grub.cfg -map $grubCfgName /isolinux/grub.conf"

wsl bash -c "$wslCmd"

if (!(Test-Path "$workDir\$isoCustomName")) {
    Write-Error "Blad: Nie udalo sie utworzyc $isoCustomName."
    return
}

if (Get-VM -Name $vmName -ErrorAction SilentlyContinue) {
    Write-Host "Usuwanie istniejacej maszyny $vmName..."
    Stop-VM -Name $vmName -Force -Confirm:$false
    Remove-VM -Name $vmName -Force -Confirm:$false
}
if (Test-Path $vhdPath) { Remove-Item $vhdPath }

Write-Host "[2/6] Tworzenie maszyny wirtualnej..."
New-VM -Name $vmName -MemoryStartupBytes 2GB -Generation 2 -NewVHDPath $vhdPath -NewVHDSizeBytes 20GB

Write-Host "[3/6] Konfiguracja procesorow i sieci..."
Set-VMProcessor -VMName $vmName -Count 2
Connect-VMNetworkAdapter -VMName $vmName -SwitchName "Default Switch"
Set-VMFirmware -VMName $vmName -EnableSecureBoot Off

Write-Host "[4/6] Montowanie obrazow ISO..."
Get-VMDvdDrive -VMName $vmName | Remove-VMDvdDrive
Add-VMDvdDrive -VMName $vmName -Path "$workDir\$isoCustomName"
Add-VMDvdDrive -VMName $vmName -Path "$workDir\$ksIsoName"

Write-Host "[5/6] Ustawianie kolejnosci bootowania..."
$dvd = Get-VMDvdDrive -VMName $vmName | Where-Object { $_.Path -eq "$workDir\$isoCustomName" }
Set-VMFirmware -VMName $vmName -FirstBootDevice $dvd

Write-Host "[6/6] Uruchamianie maszyny..." -ForegroundColor Green
Start-VM -Name $vmName

Write-Host "`nMaszyna wystartowala..." -ForegroundColor Yellow
