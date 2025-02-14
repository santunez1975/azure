Import-Module ImportExcel

# Definir la ruta del archivo Excel
$fecha = Get-Date -Format "yyyyMMdd_HHmmss"
$rutaExcel = "C:\Reportes\ClusterReport_$fecha.xlsx"

# Obtener los datos del clúster
$clusterInfo = Get-Cluster | Select-Object *
$clusterNodes = Get-ClusterNode | Select-Object *
$storagePools = Get-StoragePool | Select-Object *
$azstackServices = Get-Service *azstack* | Select-Object *
$azStackHCICluster = Get-AzStackHCICluster | Select-Object *
$azStackHCIIntents = Get-AzStackHCIIntent | Format-List | Out-String
$azureArcServices = Get-Service *azurearc* | Select-Object *
$azureArcConnectivity = Get-AzConnectedCluster | Select-Object *
$azureArcSyncStatus = Get-AzStackHCICluster | Select-Object ClusterName, AzureArcSyncStatus

# Crear un directorio para reportes si no existe
if (!(Test-Path "C:\Reportes")) {
    New-Item -ItemType Directory -Path "C:\Reportes"
}

# Exportar datos al archivo Excel
$clusterInfo | Export-Excel -Path $rutaExcel -WorksheetName "ClusterInfo" -AutoSize
$clusterNodes | Export-Excel -Path $rutaExcel -WorksheetName "ClusterNodes" -AutoSize -Append
$storagePools | Export-Excel -Path $rutaExcel -WorksheetName "StoragePools" -AutoSize -Append
$azstackServices | Export-Excel -Path $rutaExcel -WorksheetName "AzStackServices" -AutoSize -Append
$azStackHCICluster | Export-Excel -Path $rutaExcel -WorksheetName "AzStackHCICluster" -AutoSize -Append
$azStackHCIIntents | Export-Excel -Path $rutaExcel -WorksheetName "AzStackHCIIntents" -AutoSize -Append
$azureArcServices | Export-Excel -Path $rutaExcel -WorksheetName "AzureArcServices" -AutoSize -Append
$azureArcConnectivity | Export-Excel -Path $rutaExcel -WorksheetName "AzureArcConnectivity" -AutoSize -Append
$azureArcSyncStatus | Export-Excel -Path $rutaExcel -WorksheetName "AzureArcSyncStatus" -AutoSize -Append

Write-Host "Reporte generado exitosamente en: $rutaExcel"