function Update-SQLiteDatabase {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Database
    )

    Initialize-SQLiteConnection -Database $Database -Open

    # get a list of config schema
    $DesiredSchema = $DBConfig.Columns.GetEnumerator() | ForEach-Object {
        $Column = $PSItem.Name
        $DataType = $PSItem.Value.DataType

        "$Column $DataType".Trim()
    }

    Write-Verbose -Message "Desired schema is $DesiredSchema"

    $ExistingSchema = Invoke-SQLiteQuery -DataSource $Database -Query "PRAGMA table_info($($DBConfig.TableName))"

    $es = $ExistingSchema | ForEach-Object {
        $Column = $PSItem.Name
        $DataType = $PSItem.Type

        "$Column $DataType".Trim()
    }


    # Check if the table already has the desired schema
    # $query = "PRAGMA table_info($($DBConfig.TableName))"

    # $command = $conn.CreateCommand()
    # $command.CommandText = $query
    # $reader = $command.ExecuteNonQuery()
    # $reader = $command.ExecuteReader()

    # Store the schema of the existing table


    # $ExistingSchema = @()
    # while ($reader.Read()) {
    #     $ExistingSchema += [PSCustomObject]@{
    #         Name = $reader["name"]
    #         Type = $reader["type"]
    #     }
    # }

    Write-Verbose -Message "Existing schema is $es"

    # Compare the schema of the existing table with the desired schema
    $changes = Compare-Object $es $DesiredSchema -Property Name, Type
    # $changes
    Write-LogEntry -Value "Database column changes : $changes" -LogLevel Verbose

    if ($null -ne $changes) {
        # If changes are needed, alter the table to match the desired schema
        foreach ($change in $changes) {
            if ($change.SideIndicator -eq "=>") {
                Write-Verbose -Message "Database changes found."
                Write-Verbose -Message "ALTER TABLE $($DBConfig.TableName) ADD COLUMN $($column.Name) $($column.Type)"
                $column = $change.InputObject
                Write-Verbose -Message "Column to change is $column"
                $query = "ALTER TABLE $($DBConfig.TableName) ADD COLUMN $($column.Name) $($column.Type)"
                $command = $conn.CreateCommand()
                $command.CommandText = $query
                # $command
                $command.ExecuteNonQuery()
            }
        }
    }
    else {
        Write-LogEntry -Value "No changes need to be made to the database" -LogLevel Verbose
    }




    ################# OLD STUFF

    # $TableQuery = "ALTER TABLE devices ADD COLUMN NEWFIELD;"

    # $cmd = $conn.CreateCommand()

    # $cmd.CommandText = $TableQuery
    # $cmd.ExecuteNonQuery()

    # $cmd.Dispose()

    Initialize-SQLiteConnection -Database $Database -Close
}
