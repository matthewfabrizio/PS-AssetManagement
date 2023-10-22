function Get-ADQueryInformation {
    [CmdletBinding()]
    param (

    )

    # need to handle no devices found with ad query search

    # TODO : if you're not connected to domain network don't allow this to run

    begin {
        $ADFilter = Read-Host "What computer would you like to search for?"
        $ADQuery = (Get-ADComputer -Filter "Name -like '$ADFilter*'" | Select-Object -ExpandProperty Name) -join ","
        $ADQuery = $ADQuery.Split(",").Trim(" ")

        Write-LogEntry -Value "Active Directory computers to scan [$ADQuery]" -LogLevel Information -OutNull
    }

    process {
        $OnlineComputers = Test-ComputerConnection -ComputerName $ADQuery | Where-Object { $PSItem.Status -EQ "Online" -and $PSItem.WSMan -EQ $true }

        if ($OnlineComputers) {
            Write-LogEntry -Value "Successfully connected to devices [$($OnlineComputers.Computer)]" -LogLevel Information
            Get-DeviceInformation -ComputerName $OnlineComputers.Computer
        }
        else {
            Write-Warning -Message "No devices could be contacted."
        }

    }

    end {

    }
}
