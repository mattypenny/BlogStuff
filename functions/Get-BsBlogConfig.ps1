function Get-BsBlogConfig {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
       [Parameter(Mandatory = $True)][string] $BlogConfigUri,
       [Parameter(Mandatory = $True)][string]$BlogToken
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
    
    write-dbg "`$BlogToken count: <$($BlogToken.Length)>"
    write-dbg "`$BlogConfigUri: <$BlogConfigUri>"
    
    $headers = @{
       "Authorization" = "Bearer $BlogToken"
    }
    $BlogConfig = Invoke-RestMethod -Uri $BlogConfigUri -Headers $headers
    
    write-dbg "`$BlogConfig count: <$($BlogConfig.Length)>"
    write-endfunction
    
    return $BlogConfig
    
 }
 