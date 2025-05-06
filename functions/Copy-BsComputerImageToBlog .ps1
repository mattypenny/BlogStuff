function Copy-BsComputerImageToBlog {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
       [Parameter(Mandatory = $True)]$BlogConfig,
       [Parameter(Mandatory = $True)][string]$BlogName,
 
       [Parameter(Mandatory = $True)]$RestMethodHeaders,
       [Parameter(Mandatory = $True)][string]$imagePath
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
    
    write-dbg "`$BlogToken count: <$($BlogToken.Length)>"
    
    [string]$mediaEndpoint = $BlogConfig."media-endpoint"
 
    $Destination = $BlogConfig | 
    Select-Object -ExpandProperty destination |
    Where-Object name -EQ $BlogName
 
    [string]$MpDestination = $Destination.Uid
    $MpDestination = [System.Web.HttpUtility]::UrlEncode($MpDestination)
 
    $Uri = "${mediaEndpoint}?mp-destination=$MpDestination" 
 
    write-dbg "`$BlogName: <$BlogName>"
    write-dbg "`$Uri: <$Uri>"
 
    $form = @{
       file = Get-Item $imagePath
    }
    $uploadResponse = Invoke-RestMethod -Uri $Uri -Method Post -Headers $RestMethodHeaders -Form $form
    $imageUrl = $uploadResponse.Url
    write-endfunction
 
    return $imageUrl
    
    
 }
 