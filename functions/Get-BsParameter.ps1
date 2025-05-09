function Get-BsParameter {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
        $ParameterFile = "$Env:PSParametersFolder/GeneralParameters.csv",
        [Parameter(Mandatory = $True)][string]$Parameter
 
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
    
    $ParameterRow = $(import-csv $ParameterFile | 
        Where-Object Parameter -eq $Parameter)
 
    $Value = $ParameterRow.Value
    
    write-endfunction
 
    return $Value
    
}
 