#commands to manage ADReportingTools options

# color options are stored in $ADReportingToolsOptions which is defined in the root module

function Get-ADReportingToolsOptions {
    [cmdletbinding()]
    [OutputType("ADReportingToolsOption")]
    param ()

    if (Get-Variable -Name ADReportingToolsOptions) {
        # April 2, 2021 filter out Note and Reset JDH
        $ADReportingToolsOptions.GetEnumerator() | Where-Object { $_.Key -notmatch "Note|Reset"} |
        ForEach-Object {
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
        [ArgumentCompleter( { (Get-ADReportingToolsOptions).Name })]
        [string]$Name,
        [Parameter(Mandatory, HelpMessage = "Specify the opening ANSI sequence.")]
        [ValidateNotNullOrEmpty()]
        [string]$ANSI
    )

    Write-Verbose "Updating $Name"

    $ADReportingToolsOptions[$Name] = $ANSI
}

