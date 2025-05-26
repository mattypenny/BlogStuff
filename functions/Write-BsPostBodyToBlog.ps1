function Write-BsPostBodyToBlog {
   <#
 .SYNOPSIS
    xx
 #>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)] $BlogConfig,
      [Parameter(Mandatory = $True)] $RestMethodHeaders,
      [Parameter(Mandatory = $True)][string] $BlogName,
      [Parameter(Mandatory = $False)][string] $PostTitle,
      [Parameter(Mandatory = $False)]         $PostDate,
      [Parameter(Mandatory = $True)][string]  $PostBody,
      $Draft = $True
      # CrossPostToBlueSky = $False
   )
    
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
   write-startfunction
   <#
     $Destination = $BlogConfig | 
    Select-Object -ExpandProperty destination |
    Where-Object name -EQ $BlogName
 
    [string]$MpDestination = $Destination.Uid
    $MpDestination = [System.Web.HttpUtility]::UrlEncode($MpDestination)
 
    $Uri = "${mediaEndpoint}?mp-destination=$MpDestination" 
 
    write-dbg "`$BlogName: <$BlogName>"
    write-dbg "`$Uri: <$Uri>"
    #>
 
    
 
   $Destination = $BlogConfig | 
   Select-Object -ExpandProperty destination |
   Where-Object name -EQ $BlogName
 
   write-dbg "`$Destination: <$Destination>"
 
   [string]$MpDestination = $Destination.Uid
   write-dbg "`$MpDestination: <$MpDestination>"
 
   $MpDestination = 
   [System.Web.HttpUtility]::UrlEncode($MpDestination)
 
 
   $Uri = "https://micro.blog/micropub?mp-destination=$MpDestination"

   $datetimeFormat = 'ddd MMM dd HH:mm:ss K yyyy'
   $datetimeObject = [DateTime]::ParseExact($PostDate, $datetimeFormat, $null)

 
   $PostDate = $datetimeObject.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
   write-dbg "`$PostDate: <$PostDate>"

 
   $body = "h=entry&content=$([System.Web.HttpUtility]::UrlEncode($PostBody))"
 
   $body += "&published=$([System.Web.HttpUtility]::UrlEncode($PostDate))"
 
   # $Uri ="https://micro.blog/micropub?mp-destination=$MpDestination"
 
   # invoke-RestMethod -Uri https://micro.blog/micropub?mp-destination=mattypenny-test.micro.blog -Method Post -Headers $restmethodheaders -Body $body | select *
 
   write-dbg "`$body: <$body>"
 
   $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $restmethodheaders -Body $body
 
   $url = $response.url    
   $preview = $response.preview
   $edit = $response.edit   
 
   write-dbg "`$url: <$url>"
   write-dbg "`$preview: <$preview>"
   write-dbg "`$edit: <$edit>"
    
    
   write-endfunction
    
   $response
    
}
 