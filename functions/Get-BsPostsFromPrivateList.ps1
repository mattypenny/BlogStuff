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

    $startdate = '2024-08-01'
    $enddate = '2024-08-31'
    $Uri = $Uri +
    "`&start=" + [System.Web.HttpUtility]::UrlEncode($startDate) + 
    "`&end=" + [System.Web.HttpUtility]::UrlEncode($endDate)
    write-dbg "`$Uri: <$Uri>"
 
    $Token = start $(Get-BsParameter -parameter BsBlogToken)
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Content-Type"  = "application/json"
    }
 
    $i = Invoke-RestMethod -Uri $Uri -Method Get -Headers $headers

    $Posts = $i | select -expand items | select -expand properties | select post-status, published , content 
 
    foreach ($P in $Posts) {
        [string]$PostStatus = $P | Select-Object -ExpandProperty post-status 
        [datetime]$Published = $P | Select-Object -ExpandProperty published 
        [string]$Content = $P | Select-Object -ExpandProperty Content 

        [PSCustomObject]@{
            PostStatus = $PostStatus
            Published  = $Published
            Content    = $Content
        }
    }
    write-endfunction
    
    
}
 