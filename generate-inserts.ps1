Param (
    [Parameter(Mandatory=$TRUE)]
    $serverName,
    [Parameter(Mandatory=$TRUE)]
    $databaseName,
    [string[]]
    $tableNames,
    $savePath
)

#We don't want to show PowerShell loading this assembly
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null

$server = New-Object Microsoft.SqlServer.Management.Smo.Server($serverName)

$database = $server.Databases.Item($databaseName)

if (!$savePath)
{
    "No save path supplied, script will be output to C:\Temp\$databaseName" + "_Inserts.sql"
    $savePath = "C:\Temp"
}

$savePath = $savePath.TrimEnd("\","/") + "\" + $database.Name + "_inserts.sql"

$scripter = New-Object Microsoft.SqlServer.Management.Smo.Scripter($server)
$scripter.Options.WithDependencies = $TRUE
$scripter.Options.ScriptData = $TRUE
$scripter.Options.ScriptSchema = $FALSE
$scripter.Options.FileName = $savePath

$tb = New-Object Microsoft.SqlServer.Management.Smo.Table
$smoObjects = $tb.Urn

if ($tableNames.Count -eq 0)
{
    "No tables supplied, using all tables that are not system objects instead"

    $tablesToUse = $database.Tables | Where-Object {
        $_.IsSystemObject -eq $FALSE
    }
}
else 
{
    $tempTables = [System.Collections.ArrayList]@()
    
    foreach ($table in $database.Tables)
    {
        foreach ($tableName in $tableNames)
        {
            if ($table.Name -eq $tableName)
            {
                # For some reason, PowerShell output 0 1 when adding to a list
                $tempTables.Add($table) | Out-Null
            }
        }
    }
    
    $tablesToUse = $tempTables
}

$allTableNames = ""

foreach ($table in $tablesToUse)
{
    $allTableNames += "$table.Name, "
}

$allTableNames = $allTableNames.TrimEnd(" ",",")

"Starting output of the tables: $allTableNames"
"Generating insert scripts"
$scripter.EnumScript(@($tablesToUse)) | Out-Null
"Completed generating insert scripts. Script output to $savePath"
