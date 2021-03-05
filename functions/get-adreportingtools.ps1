function Get-ADReportingTools {
    [cmdletbinding()]
    [OutputType("ADReportingTool")]
    param ()

    $cmds = (Get-Module adreportingtools).ExportedFunctions.keys | Get-Command
    $all = foreach ($cmd in $cmds) {
        [PSCustomObject]@{
            PSTypeName = "ADReportingTool"
            Name = $cmd.Name
            Verb = $cmd.Verb
            Noun = $cmd.Noun
            Version = $cmd.Version
            Alias = (Get-Alias -Definition $cmd.name -ErrorAction SilentlyContinue).Name
            Synopsis = (Get-Help $cmd.name).Synopsis
        }
    }
    #write sorted results to the pipeline
    $all | Sort-Object -Property Verb,Name
}