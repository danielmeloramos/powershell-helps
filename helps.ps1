#variaveis - globais
Param(
    [string]$Server = "LAPTOP-OUHP325G", #server name
    [string]$DB = "", #nome-banco
    [string]$user, #usuario
    [string]$Pwd, #senha
    [string]$Script = [IO.File]::ReadAllText("D:\bkp\script\tabelas.sql") #caminho
)

#banco - criar
$srv = new-Object Microsoft.SqlServer.Management.Smo.Server("(local)")
$db = New-Object Microsoft.SqlServer.Management.Smo.Database($srv, "banco")
$db.Create()
Write-Host $db.CreateDate

#tabela - criar
$batches = $Script -split "GO\r\n"
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $Server; Database = $sqlDBName; Integrated Security = True"
$SqlConnection.Open()

foreach($batch in $batches)
{
    if ($batch.Trim() -ne ""){

        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $batch
        $SqlCmd.Connection = $SqlConnection
        $SqlCmd.ExecuteNonQuery()
    }
}
$SqlConnection.Close()

#Chave de registro - Add
$Key = "HKEY_CURRENT_USER\TEST"
If  ( -Not ( Test-Path "Registry::$Key")){New-Item -Path "Registry::$Key" -ItemType RegistryKey -Force}
Set-ItemProperty -path "Registry::$Key" -Name "Less" -Type "String" -Value "Less"

#Chave de registro - Remove
Remove-ItemProperty -path "Registry::$Key" -Name "Less"

#banco - remover
$Server = new-Object Microsoft.SqlServer.Management.Smo.Server("(local)")
$DatabaseName = "banco"
$DBObject = $Server.Databases[$DatabaseName]
if ($DBObject)
{
    $Server.KillDatabase($DatabaseName)
}
