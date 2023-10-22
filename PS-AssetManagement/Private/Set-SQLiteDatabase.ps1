function Set-SQLiteDatabase {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Database,

        [Parameter()]
        [psobject]
        $Data
    )

    $Data

    if (Test-Path $Database) {
        $names = ($Data.PSObject.Properties.Name).Replace(" ", "_") | Join-String -Separator ','
        $values = ($Data.PSObject.Properties.Value) | Join-String -SingleQuote -Separator ','

        $insert = "
        INSERT OR REPLACE INTO $($DBConfig.TableName)($names)
        VALUES ($values)"

        Write-LogEntry -Value "Values inserting into database: $insert" -LogLevel Verbose -OutNull

        Initialize-SQLiteConnection -Database $Database -Open

        $cmd = $conn.CreateCommand()

        $cmd.CommandText = $insert
        Write-LogEntry -Value $cmd.CommandText -LogLevel Information -OutNull
        $cmd.ExecuteNonQuery()

        $cmd.Dispose()

        Initialize-SQLiteConnection -Database $Database -Close
    }
    else {
        Write-Output "Could not connect to $Database"
    }

}
