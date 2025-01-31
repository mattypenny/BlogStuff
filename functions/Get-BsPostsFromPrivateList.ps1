function Get-BsPostsFromPrivateList {
    <#
 .SYNOPSIS
    xx
 #>
    [CmdletBinding()]
    param (
 
    [string]$BlogName = $(Get-BsParameter -parameter BsBlogName),
        [string][ValidateSet('main', 'test', 'tweets')]$BlogShortName = 'main',
        [switch]$Full = $False
    )
    
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
    
    write-startfunction
 
    $URi = switch ($BlogShortName) {
        'main' {  
            $(Get-BsParameter -parameter BsBlogName)
        }
        'test' {  
            $(Get-BsParameter -parameter BsTestBlogName)
        }
        'tweets' {  
            $(Get-BsParameter -parameter BsTweetsBlogName)
        }
        Default { $BlogName }
    }
    
    $Uri = "https://micro.blog/micropub?q=source`&mp-destination=https%3a%2f%2f$BlogName%2f"
    $Uri = "https://micro.blog/micropub?q=source"

    # $startdate = '2024-08-01'
    # $enddate = '2024-08-31'
    # $Uri = $Uri +
    # "`&start=" + [System.Web.HttpUtility]::UrlEncode($startDate) + 
    # "`&end=" + [System.Web.HttpUtility]::UrlEncode($endDate)


    $Uri = "https://micro.blog/posts/mattypenny/all"

    write-dbg "`$Uri: <$Uri>"
 
    $Token = $(Get-BsParameter -parameter BsBlogToken)
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
 
    $i = Invoke-RestMethod -Uri $Uri -Method Get -Headers $headers

    $i
# 20240111    $Posts = $i | select -expand items | select -expand properties | select post-status, published , content 
# 20240111 
# 20240111    foreach ($P in $Posts) {
# 20240111        [string]$PostStatus = $P | Select-Object -ExpandProperty post-status 
# 20240111        [datetime]$Published = $P | Select-Object -ExpandProperty published 
# 20240111        [string]$Content = $P | Select-Object -ExpandProperty Content 
# 20240111
# 20240111        [PSCustomObject]@{
# 20240111            PostStatus = $PostStatus
# 20240111            Published  = $Published
# 20240111            Content    = $Content
# 20240111        }
# 20240111    }
    write-dbg "`$Uri: <$Uri>"
    write-endfunction
    
    
}
 