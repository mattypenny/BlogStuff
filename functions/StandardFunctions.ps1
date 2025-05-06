

function write-dbg {
    <#
    .SYNOPSIS
       xx
    #>
    [CmdletBinding()]
    param (
       $DebugText 
    )
       
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    write-debug $DebugText
       
 }
    
 
 function write-startfunction {
    <#
    .SYNOPSIS
       xx
    #>
    [CmdletBinding()]
    param (
       
    )
       
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
       
       
       
 }
    
 function write-endfunction {
    <#
    .SYNOPSIS
       xx
    #>
    [CmdletBinding()]
    param (
       
    )
       
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
       
       
       
 }
 
 