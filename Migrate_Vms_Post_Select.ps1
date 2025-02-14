# Ejecuta el script en PowerShell como Administrador en un nodo del clúster Hyper-V llamado .\Migrar-VM-Interactivo.ps1
#  1. Mostrara una lista con todas las VMs apagadas
#  2. Seleccionae la VM que deseas migrar hacia Azure Local.
#  3. Se migrará la VM al clúster Azure Local, asignará el Virtual Switch y la agregará al clúster

# Definir parámetros del clúster de destino
$ClusterDestino = "ClusterHCI"  # Nombre del clúster Azure Stack HCI
$NodoDestino = "NodoHCI01"  # Nodo donde se importará la VM
$ClusterStoragePath = "C:\ClusterStorage\Volume1\VMs"  # Ruta en almacenamiento compartido
$VMSwitch = "SwitchVirtual"  # Nombre del Virtual Switch en Azure Stack HCI
$ExportPath = "\\Servidor\Exportacion"  # Ruta compartida para exportar la VM

# Obtener todas las VMs apagadas en el clúster Hyper-V
Write-Host "Obteniendo todas las VMs apagadas en el clúster Hyper-V..."
$VMsApagadas = Get-ClusterGroup | Where-Object { $_.GroupType -eq "VirtualMachine" } | 
    Get-VM | Where-Object { $_.State -eq "Off" }

if ($VMsApagadas.Count -eq 0) {
    Write-Host "No hay VMs apagadas en el clúster Hyper-V." -ForegroundColor Red
    exit
}

# Mostrar lista de VMs apagadas y permitir selección
Write-Host "Seleccione una VM para migrar:"
$VMSeleccionada = $VMsApagadas | Out-GridView -PassThru

if (-not $VMSeleccionada) {
    Write-Host "No se seleccionó ninguna VM. Saliendo..." -ForegroundColor Yellow
    exit
}

$VMName = $VMSeleccionada.Name
Write-Host "Se migrará la VM: $VMName" -ForegroundColor Green

# Exportar la VM desde el clúster Hyper-V
Write-Host "Exportando VM '$VMName' desde Hyper-V..."
Export-VM -Name $VMName -Path $ExportPath -Force

# Importar la VM en Azure Stack HCI
Write-Host "Importando VM en el nodo '$NodoDestino'..."
$ImportedVM = Import-VM -Path "$ExportPath\$VMName" -Copy -GenerateNewId -ComputerName $NodoDestino -Passthru

# Mover la VM al almacenamiento compartido del clúster
Write-Host "Moviendo VM '$VMName' a almacenamiento compartido..."
Move-VMStorage -VMName $VMName -DestinationStoragePath $ClusterStoragePath -ComputerName $NodoDestino

# Asignar Virtual Switch
Write-Host "Asignando Virtual Switch '$VMSwitch' a la VM..."
Get-VM -Name $VMName -ComputerName $NodoDestino | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName $VMSwitch

# Agregar la VM al clúster
Write-Host "Agregando VM '$VMName' al clúster Azure Stack HCI..."
Add-ClusterVirtualMachineRole -VMName $VMName

Write-Host "Migración completada. La VM '$VMName' está lista en el clúster Azure Stack HCI." -ForegroundColor Cyan