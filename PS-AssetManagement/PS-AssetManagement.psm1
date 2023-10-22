$ModuleRoot = $PSScriptRoot

# load config files
$DBConfigPath = Join-Path -Path $ModuleRoot -ChildPath ".config\Config.psd1"
$Script:DBConfig = Import-PowerShellDataFile -Path "$DBConfigPath"

$ConfigPath = Join-Path -Path $ModuleRoot -ChildPath ".config\CimParameters.psd1"
$Script:Config = Import-PowerShellDataFile -Path "$ConfigPath"

$Script:DatabaseName = $DBConfig.Database

#Pick and import assemblies:
if ($PSEdition -eq 'core') {
    if ($isLinux) {
        write-verbose "loading linux-x64 core"
        $SQLiteAssembly = Join-path $PSScriptRoot "lib\core\linux-x64\System.Data.SQLite.dll"
    }

    if ($isMacOS) {
        write-verbose "loading mac-x64 core"
        $SQLiteAssembly = Join-path $PSScriptRoot "lib\core\osx-x64\System.Data.SQLite.dll"
    }

    if ($isWindows) {
        if ([IntPtr]::size -eq 8) {
            #64
            write-verbose "loading win-x64 core"
            $SQLiteAssembly = Join-path $PSScriptRoot "lib\core\win-x64\System.Data.SQLite.dll"
        } elseif ([IntPtr]::size -eq 4) {
            #32
            write-verbose "loading win-x32 core"
            $SQLiteAssembly = Join-path $PSScriptRoot "lib\core\win-x86\System.Data.SQLite.dll"
        }
    }
    write-verbose -message "is PS Core, loading dotnet core dll"
} elseif ([IntPtr]::size -eq 8) { #64
    write-verbose -message "is x64, loading..."
    $SQLiteAssembly = Join-path $PSScriptRoot "lib\x64\System.Data.SQLite.dll"
} else {
    throw "Failed to import assembly."
}

# Dot source public/private functions
$public = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Public/*.ps1')  -Recurse -ErrorAction Stop)
$private = @(Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Private/*.ps1') -Recurse -ErrorAction Stop)
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    } catch {
        throw "Unable to dot source [$($import.FullName)]"
    }
}

Export-ModuleMember -Function $public.Basename
