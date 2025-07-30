function Invoke-CopyBsComputerImageToBlog {
    <#
.SYNOPSIS
   xx
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$BlogName,
        [Parameter(Mandatory = $True)][string]$PhotoFolder,
        [Parameter(Mandatory = $True)][string]$PhotoName
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction
   
    [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
    [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)
      
    $BlogConfig = Get-BsBlogConfig -BlogConfigUri $BlogConfigUri -BlogToken $BlogToken

    $Photos = Get-ChildItem -Path $PhotoFolder -Filter "*$PhotoName*"
        
    $URLs = foreach ($Photo in $Photos) {
        $Image = $Photo.FullName
        write-dbg "`$Image: <$Image>"
        $headers = @{
            "Authorization" = "Bearer $BlogToken"
        }
        $Params = @{
            RestMethodHeaders = $headers
            ImagePath         = $Image
            BlogConfig        = $BlogConfig
            BlogName          = $BlogName
        }
        $BlogIMageURl = Copy-BsComputerImageToBlog @Params
        write-dbg "`$BlogIMageURl: <$BlogIMageURl>"
        $BlogIMageURl  
    }
   
    write-endfunction
    return $URLS
   
   
}
set-alias post-bsphoto Invoke-CopyBsComputerImageToBlog