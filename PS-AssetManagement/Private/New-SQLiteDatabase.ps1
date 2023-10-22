function New-SQLiteDatabase {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Database
    )

    if (-not (Test-Path $Database)) {
        Initialize-SQLiteConnection -Database $Database -Open

        $DBCreateString = $DBConfig.Columns.GetEnumerator() | ForEach-Object {
            $Column = $PSItem.Name
            $DataType = $PSItem.Value.DataType
            $NullStatus = $PSItem.Value.Null
            $KeyStatus = $PSItem.Value.Key

            "$Column $DataType $NullStatus $KeyStatus".Trim()
        }

        $DBCreateString = $DBCreateString -join ","

        $TableQuery = "CREATE TABLE IF NOT EXISTS $($DBConfig.TableName) ($DBCreateString);"

        $UniqueIndex = "CREATE UNIQUE INDEX $($DBConfig.DatabaseIndex) ON $($DBConfig.TableName)($($DBConfig.UniqueIndex));"

        $cmd = $conn.CreateCommand()

        $cmd.CommandText = $TableQuery
        $cmd.ExecuteNonQuery()

        $cmd.CommandText = $UniqueIndex
        $cmd.ExecuteNonQuery()

        $cmd.Dispose()

        Initialize-SQLiteConnection -Database $Database -Close
    }
    else {
        Write-LogEntry -Value "Database already exists." -LogLevel Verbose
    }

}
