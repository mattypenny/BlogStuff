function Get-BsParameter {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
       $ParameterFile = "$PSParametersFolder/GeneralParameters.csv",
       [Parameter(Mandatory = $True)][string]$Parameter
 
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
    
    $ParameterRow = $(import-csv $PSParametersFolder/GeneralParameters.csv | 
       Where-Object Parameter -eq $Parameter)
 
    $Value = $ParameterRow.Value
    
    write-endfunction
 
    return $Value
    
 }
 