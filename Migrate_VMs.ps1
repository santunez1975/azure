#PowerShell para Migrar Múltiples VMs Apagadas, Encenderlas y Asignar Virtual Switch
#Pasos del Script:
#
#   Identifica todas las VMs apagadas en el clúster Hyper-V.
#    Realiza la migración de todas las VMs apagadas a Azure Stack HCI.
#    Enciende todas las VMs migradas en el clúster Azure Stack HCI.
#    Asigna el Virtual Switch a todas las VMs migradas.


# Definir variables
$SourceHost = "HYPERV-NODO1"  # Nodo Hyper-V origen
$DestinationHost = "HCI-NODO1"  # Nodo Azure Stack HCI destino
$DestinationPath = "\\HCI-NODO1\C$\ClusterStorage\Volume1\VirtualMachines\"  # Ruta en Azure Stack HCI
$SwitchName = "vSwitchHCI"  # Nombre del switch virtual en Azure Stack HCI

# Obtener todas las VMs apagadas en el nodo Hyper-V
$StoppedVMs = Get-VM -ComputerName $SourceHost | Where-Object {$_.State -eq "Off"}

if ($StoppedVMs.Count -eq 0) {
    Write-Host "No hay VMs apagadas para migrar. Saliendo..."
    exit
}

foreach ($VM in $StoppedVMs) {
    $VMName = $VM.Name
    Write-Host "Migrando la VM apagada: $VMName..."

    # Realizar la migración de la VM apagada al clúster Azure Stack HCI
    Move-VM -Name $VMName -ComputerName $SourceHost -DestinationHost $DestinationHost -IncludeStorage -DestinationStoragePath $DestinationPath

    Write-Host "Migración de la VM $VMName completada."

    # Asignar el Virtual Switch a la VM en Azure Stack HCI
    Write-Host "Asignando Virtual Switch a la VM $VMName en Azure Stack HCI..."
    Get-VMNetworkAdapter -VMName $VMName -ComputerName $DestinationHost | Set-VMNetworkAdapter -SwitchName $SwitchName

    # Encender la VM en el clúster Azure Stack HCI
    Write-Host "Encendiendo la VM $VMName en Azure Stack HCI..."
    Start-VM -Name $VMName -ComputerName $DestinationHost

    Write-Host "La VM $VMName ha sido migrada, encendida y conectada al switch virtual $SwitchName."
}

Write-Host "Todas las VMs apagadas han sido migradas, encendidas y configuradas exitosamente."
