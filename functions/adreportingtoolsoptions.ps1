#commands to manage ADReportingTools options

#define color options

#use $([char]0x1b) because it will work in Windows PowerShell and PowerShell 7.

$ADReportingToolsOptions = @{
    DistributionList   = "$([char]0x1b)[92m"
    Alert              = "$([char]0x1b)[91m"
    Warning            = "$([char]0x1b)[38;5;220m"
    Universal          = "$([char]0x1b)[38;5;170m"
    DomainLocal        = "$([char]0x1b)[38;5;191m"
    Other              = "$([char]0x1b)[38;5;212m"
    Protected          = "$([char]0x1b)[38;5;199m"
    Container          = "$([char]0x1b)[38;5;1456m"
    OrganizationalUnit = "$([char]0x1b)[38;5;191m"
    DomainDNS          = "$([char]0x1b)[1;4;38;5;227m"
    UserClass          = "$([char]0x1b)[30;104m"
    GroupClass         = "$([char]0x1b)[30;48;5;94m"
    ComputerClass      = "$([char]0x1b)[30;48;5;50m"
    IsDC               = "$([char]0x1b)[38;5;155m"
    IsServer           = "$([char]0x1b)[38;5;50m"
}

function Get-ADReportingToolsOptions {
    [cmdletbinding()]
    [OutputType("ADReportingToolsOption")]
    param ()

    if (Get-Variable -Name ADReportingToolsOptions) {
        $ADReportingToolsOptions.GetEnumerator() | ForEach-Object {
            [pscustomobject]@{
                PSTypename = "ADReportingToolsOption"
                Name       = $_.key
                Value      = "{0}{1}$([char]0x1b)[0m" -f $_.value, ($_.value -replace $([char]0x1b), "`$([char]0x1b)")
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
        [Parameter(Position = 0, Mandatory, HelpMessage = "Specify an option.")]
        [ValidateNotNullOrEmpty()]
        #[ValidateSet("DistributionList","Alert","Warning")]
        [ArgumentCompleter( { (Get-ADReportingToolsOptions).Name })]
        [string]$Name,
        [Parameter(Mandatory, HelpMessage = "Specify the opening ANSI sequence.")]
        [ValidateNotNullOrEmpty()]
        [string]$ANSI
    )

    Write-Verbose "Updating $Name"

    $ADReportingToolsOptions[$Name] = $ANSI
}

