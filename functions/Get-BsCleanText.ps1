
function Get-BsCleanText {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
       [Parameter(Mandatory = $True)][string] $DirtyText
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
 
    # Use a regex to replace HTML tags with nothing
    $CleanText = $DirtyText -replace '<[^>]*>', ''
 
    # Replace common HTML entities with their corresponding characters
    $CleanText = $CleanText -replace '&rsquo;', "'"
    $CleanText = $CleanText -replace '&lsquo;', "'"
    $CleanText = $CleanText -replace '&rdquo;', '"'
    $CleanText = $CleanText -replace '&ldquo;', '"'
    $CleanText = $CleanText -replace '&ndash;', '-'
    $CleanText = $CleanText -replace '&mdash;', '-'
    $CleanText = $CleanText -replace '&amp;', '&'
    $CleanText = $CleanText -replace '&lt;', '<'
    $CleanText = $CleanText -replace '&gt;', '>'
    $CleanText = $CleanText -replace '&nbsp;', ' '
    # Add more replacements as needed
 
    return $CleanText
 }