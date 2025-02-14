Import-Module ImportExcel

# Definir la ruta del archivo Excel
$fecha = Get-Date -Format "yyyyMMdd_HHmmss"
$rutaExcel = "C:\Reportes\ClusterReport_$fecha.xlsx"
$rutaLog = "C:\Reportes\ClusterReport_$fecha.log"

# Función para registrar eventos en el log
Function Write-Log {
    param ([string]$message)
    "$((Get-Date).ToString("yyyy-MM-dd HH:mm:ss")) - $message" | Out-File -Append -FilePath $rutaLog
}

Write-Log "Inicio de la generación del reporte."

# Captura de datos con manejo de errores
Function Get-Data {
    param ([scriptblock]$Command, [string]$Description)
    try {
        Write-Log "Ejecutando: $Description"
        &$Command | Select-Object *
    } catch {
        Write-Log "Error en $Description: $_"
        $null
    }
}

# Obtener datos del clúster
$clusterInfo = Get-Data -Command {Get-Cluster} -Description "Estado del Clúster"
$clusterNodes = Get-Data -Command {Get-ClusterNode} -Description "Estado de los Nodos"
$storagePools = Get-Data -Command {Get-StoragePool} -Description "Configuración de Almacenamiento"
$azstackServices = Get-Data -Command {Get-Service *azstack*} -Description "Servicios de Azure Stack HCI"
$azStackHCICluster = Get-Data -Command {Get-AzStackHCICluster} -Description "Sincronización con Azure"
$azStackHCIIntents = Get-Data -Command {Get-AzStackHCIIntent | Format-List *} -Description "Intents de Azure Stack HCI"
$azureArcServices = Get-Data -Command {Get-Service *azurearc*} -Description "Servicios de Azure Arc"
$azureArcConnectivity = Get-Data -Command {Get-AzConnectedCluster} -Description "Conectividad de Azure Arc"
$azureArcSyncStatus = Get-Data -Command {Get-AzStackHCICluster | Select-Object ClusterName, AzureArcSyncStatus} -Description "Estado de Sincronización de Azure Arc"

# Crear un directorio para reportes si no existe
if (!(Test-Path "C:\Reportes")) {
    New-Item -ItemType Directory -Path "C:\Reportes"
}

# Exportar datos al archivo Excel con formato avanzado
Write-Log "Exportando datos a Excel."
$excelParams = @{Path=$rutaExcel; AutoSize=$true}
$clusterInfo | Export-Excel @excelParams -WorksheetName "ClusterInfo"
$clusterNodes | Export-Excel @excelParams -WorksheetName "ClusterNodes" -Append
$storagePools | Export-Excel @excelParams -WorksheetName "StoragePools" -Append
$azstackServices | Export-Excel @excelParams -WorksheetName "AzStackServices" -Append
$azStackHCICluster | Export-Excel @excelParams -WorksheetName "AzStackHCICluster" -Append
$azStackHCIIntents | Export-Excel @excelParams -WorksheetName "AzStackHCIIntents" -Append
$azureArcServices | Export-Excel @excelParams -WorksheetName "AzureArcServices" -Append
$azureArcConnectivity | Export-Excel @excelParams -WorksheetName "AzureArcConnectivity" -Append
$azureArcSyncStatus | Export-Excel @excelParams -WorksheetName "AzureArcSyncStatus" -Append

# Agregar gráficos y formato condicional
$excel = Open-ExcelPackage -Path $rutaExcel
$ws = $excel.Workbook.Worksheets["ClusterInfo"]
Set-ExcelRange -Worksheet $ws -Range "A1:Z1" -Bold -FontSize 12 -BackgroundColor Yellow
Close-ExcelPackage $excel

Write-Log "Reporte generado exitosamente en: $rutaExcel"
