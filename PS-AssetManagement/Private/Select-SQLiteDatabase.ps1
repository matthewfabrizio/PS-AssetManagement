function Select-SQLiteDatabase {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Database,

        [Parameter(ValueFromPipeline)]
        [string]
        $Query
    )
    
    begin {
        Initialize-SQLiteConnection -Database $Database -Open
    }

    process {
        $cmd = $conn.CreateCommand()
        $cmd.CommandText = $Query
    
        $Adapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter($cmd)
        $DataSet = New-Object System.Data.DataSet
    
        $Adapter.Fill($DataSet)
    
        $DataSet.Tables
    
        $cmd.Dispose()
    }

    end {
        Initialize-SQLiteConnection -Database $Database -Close
    }
}
