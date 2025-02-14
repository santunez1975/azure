# Script Migracion, Reportes Azure.
Los codigos en powershell, se desarrollaron para realizar procesos de migracion de datos desde Hyper-V hacia Azure Stack HCI 22H2.

Cluster_Status.ps1 = Extrae el estado del cluster Azure Local. 

Cluster_Status_v1.ps1 = Extrae el estado del cluster Azure Local. Exporta datos al archivo Excel con formato avanzado

Migrate_VMs.ps1 = PowerShell para Migrar Múltiples VMs Apagadas, Encenderlas y Asignar Virtual Switch desde Hyper-V a Azure Local

Migrate_Vms_Post_Select.ps1 = Muestra las VMs apagadas en el cluster de Hyper-V, se selecciona una VM y la migra hacia Azure Local.
