# Parametry
$vmName = "Fedora-kanye"
$vhdPath = "C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\$vmName.vhdx"
$isoPath = "C:\Users\kubar\Downloads\Fedora-Everything-netinst-x86_64-44-1.7.iso"
$switchName = "Default Switch"

# 1. Tworzenie dysku twardego
New-VHD -Path $vhdPath -SizeBytes 20GB -Dynamic

# 2. Tworzenie Maszyny Wirtualnej 
New-VM -Name $vmName -MemoryStartupBytes 2GB -Generation 2 -Path "C:\Users\Public\Documents\Hyper-V" -SwitchName $switchName

# 3. Podpięcie dysku i ISO
Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath
Add-VMDvdDrive -VMName $vmName -Path $isoPath

# 4. Wyłączenie Secure Boot
Set-VMFirmware -VMName $vmName -EnableSecureBoot Off

# 5. Uruchomienie maszyny
Start-VM -Name $vmName

Write-Host "Maszyna uruchomiona. Polacz sie z nia i dopisz inst.ks w GRUB!" -ForegroundColor Cyan