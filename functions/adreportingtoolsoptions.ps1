#commands to manage ADReportingTools options

#define color options

#use $([char]0x1b) because it will work in Windows PowerShell and PowerShell 7.

$ADReportingToolsOptions = @{
    DistributionList = "$([char]0x1b)[92m"
    Alert = "$([char]0x1b)[91m"
    Warning = "$([char]0x1b)[38;5;220m"
    Universal = "$([char]0x1b)[38;5;170m"
    DomainLocal = "$([char]0x1b)[38;5;191m"
}

function Get-ADReportingToolsOptions {
    [cmdletbinding()]
    [OutputType("ADReportingToolsOption")]
    param ()

    if (Get-Variable -Name ADReportingToolsOptions) {
        $ADReportingToolsOptions.GetEnumerator() | Foreach-Object {
            [pscustomobject]@{
                PSTypename = "ADReportingToolsOption"
                Name = $_.key
                Value = "{0}{1}$([char]0x1b)[0m" -f $_.value,($_.value -replace $([char]0x1b),"`$([char]0x1b)")
            }
        } #foreach
    } #if variable found
    else {
        Write-Warning "Cant' find the `$ADReportingToolsOptions variable."
    }
}

function Set-ADReportingToolsOptions {
    [cmdletbinding()]
    [OutputType("None")]
    param (
        [Parameter(Position = 0,Mandatory,HelpMessage = "Specify an option.")]
        [ValidateNotNullOrEmpty()]
        #[ValidateSet("DistributionList","Alert","Warning")]
        [ArgumentCompleter({(Get-ADReportingToolsOptions).Name})]
        [string]$Name,
        [Parameter(Mandatory,HelpMessage = "Specify the opening ANSI sequence.")]
        [ValidateNotNullOrEmpty()]
        [string]$ANSI
    )

        Write-Verbose "Updating $Name"

        $ADReportingToolsOptions[$Name] = $ANSI
}

