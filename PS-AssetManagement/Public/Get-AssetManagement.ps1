# function to start the module; rename when done

function Get-AssetManagement {
    [CmdletBinding()]
    param ()

    Write-LogEntry -Reset

    Get-Menu -Title "Asset Management"

}
