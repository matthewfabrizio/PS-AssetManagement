function Get-ADOUQueryInformation {
    [CmdletBinding()]
    param (

    )

    begin {
        # this part is kinda rough implementing in a new env; needs some more dynamic changes
        # maybe config.json could have a way to define your AD structure; i.e. root ou, sub ou, computer ou

        # source : https://adamtheautomator.com/get-adcomputer-powershell/
        # Calculate the OUs from config.json
        $OUList = [System.Collections.Generic.List[psobject]]::new()
        foreach ($OU in $DomainOUs) { $OUList += New-Object -TypeName psobject -Property @{ OU = $OU } }

        if (!$DomainOUs) { Write-Warning -Message "You need to setup your Organizational Units in Config.json"; exit }

        # modified example from https://stackoverflow.com/questions/55152044/making-a-dynamic-menu-in-powershell
        Clear-Host
        Write-Host "Choose an OU to scan" -ForegroundColor Yellow
        Write-Host "**Organizational Units can be defined within the config.json file**`n" -ForegroundColor Yellow

        "----------- OU -------------"
        foreach ($MenuItem in $OUList) { '{0} - {1}' -f ($OUList.IndexOf($MenuItem) + 1), $MenuItem.OU }
        "----------------------------`n"

        $ChoiceValid = $false
        do {
            $Choice = Read-Host 'Make a selection'

            if ($Choice -notin 1..$OUList.Count) { Write-Warning -Message ('Please select an option') }
            else { $ChoiceValid = $true }
        } while (!$ChoiceValid)

        # Store selected menu item
        if ($Choice -eq 1) {
            $Script:SelectedOU = $OUList.OU
        } else {
            $Script:SelectedOU = $OUList.OU[$Choice - 1]
        }


        $SearchBase = "OU=$SelectedOU,OU=Berks Career and Technology Center,$DomainDN"

        try {
            $SearchBaseOUs = (Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase "$SearchBase" -SearchScope Subtree).Name
        } catch {
            Write-Warning "SearchBase [$SearchBase] is not valid. Please modify config.json/ActiveDirectory/OrganizationalUnits"; exit
        }


        $OUSelected = $false
        do {
            $SearchOU = Read-Host "What OU do you want to scan in $SearchBase ( Enter[All] | list )"

            if ($SearchOU -eq 'list') {
                Clear-Host
                "`n"; (Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase "$SearchBase" -SearchScope Subtree).Name; "`n"
                $OUSelected = $false
            } else {
                $SearchBase = (Get-ADOrganizationalUnit -Filter "Name -like '$SearchOU'" -SearchBase "OU=$SelectedOU,$DomainDN").DistinguishedName
                $OUSelected = $true
            }
        } while (!$OUSelected)

        Write-Verbose "SearchBase = $SearchBase"

        $OUQuery = (Get-ADComputer -Filter * -SearchBase $SearchBase -SearchScope Subtree).Name
        $OUQuery = $OUQuery.Split(",").Trim(" ")
    }

    process {
        $OnlineComputers = Test-ComputerConnection -ComputerName $ADQuery | Where-Object { $PSItem.Online -EQ $true -and $PSItem.WSMan -EQ $true }
        Get-DeviceInformation -ComputerName ($OnlineComputers.Computer | Sort-Object)
    }

    end {

    }
}

