function Remove-BsBulkPost {
<#
.SYNOPSIS
  xx
#>
  [CmdletBinding()]
  param (
    
        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken),
       [string][ValidateSet('test', 'tweets')]$BlogShortName = 'test',
       
       [int]$NumberOfPosts = 20,
       [switch]$NoConfirm = $false
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
 # https://micro.blog/micropub?mp-destination=https://mattypenny-tweets.micro.blog`&q=source`&offset=0`&limit=30
 $Uri = "https://micro.blog/micropub?mp-destination=$MpDestination" + 
    "&q=source" + "&offset=0" + "&limit=$NumberOfPosts"

write-dbg "`$Uri: <$Uri>"


# Send the DELETE request
$Posts = Invoke-RestMethod -Uri $uri -Headers $RestMethodHeaders -Method Get |
    select-object -ExpandProperty items | 
    select-object -ExpandProperty Properties 
    

foreach ($Post in $Posts) {
    $Published = $Post | Select-Object -ExpandProperty published | Select-Object -first 1
    $Content = $Post | Select-Object -ExpandProperty content | Select-Object -first 1
    $Url = $Post | Select-Object -ExpandProperty url | Select-Object -first 1

    $Content = $Content.Substring(0, [math]::Min(140, $Content.Length))

    if ($NoConfirm) {
        Remove-BSPost -BlogShortName $BlogShortName -PostUri $Url
        write-host "Deleted post: $Published - $Url - $Content"
        start-sleep -Seconds 2
    } else {
        write-host "Delete post?: $Published - $Url - $Content"
        read-Host -Prompt "Press Enter to delete or Ctl-C to cancel"

        Remove-BSPost -BlogShortName $BlogShortName -PostUri $Url
    }

}
  
  write-endfunction
  
  
}