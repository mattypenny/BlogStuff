function Remove-BsBulkPost {
<#
.SYNOPSIS
  xx
#>
  [CmdletBinding()]
  param (
    
        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken),
       [string][ValidateSet('test', 'tweets')]$BlogShortName = 'test',
       
       [int]$NumberOfPosts = 20
  )
  
  $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
  
  write-startfunction
  
    if ($BlogShortName -eq 'test') {
        $BlogName = $(Get-BsParameter -parameter BsTestBlogName)
    } elseif ($BlogShortName -eq 'tweets') {
        $BlogName = $(Get-BsParameter -parameter BsTweetsBlogName)

    } else {
        throw "Invalid BlogShortName"
    }
    
    write-dbg "`$BlogName: <$BlogName>"
    # throw an error if the BlogName does not contain either '-test.micro.blog' or '-tweets.micro.blog'
    if ($BlogName -notmatch '-test.micro.blog|-tweets.micro.blog') {
        throw "Invalid BlogName"
    }


        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)

  
        $SplatParams = @{
            BlogConfigUri = $BlogConfigUri
            BlogToken     = $BlogToken
        }
        
        $BlogConfig = Get-BsBlogConfig @SplatParams


   $Destination = $BlogConfig | 
   Select-Object -ExpandProperty destination |
   Where-Object name -EQ $BlogName

   write-dbg "`$Destination: <$Destination>"

   [string]$MpDestination = $Destination.Uid
   write-dbg "`$MpDestination: <$MpDestination>"

   $MpDestination = 
   [System.Web.HttpUtility]::UrlEncode($MpDestination)



        
        $RestMethodHeaders = @{
            "Authorization" = "Bearer $BlogToken"
        }
  
 # building somthing that looks like this:
 # https://micro.blog/micropub?mp-destination=https://mattypenny-tweets.micro.blog`&url=https://mattypenny-tweets.micro.blog/2022/12/31/1609327355398443008.html`&action=delete -Method post -Header $RestMethodHeaders
$Uri = "https://micro.blog/micropub?mp-destination=$MpDestination"

???got here
write-dbg "`$Uri: <$Uri>"


# Send the DELETE request
Invoke-RestMethod -Uri $uri -Headers $RestMethodHeaders -Method Get

  
  write-endfunction
  
  
}