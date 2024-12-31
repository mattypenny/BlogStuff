function Get-BsPostsFromPublicFeed {
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
    
    write-dbg "`$Uri: <$Uri>"
    $Uri = $Uri + '/feed.json'
    write-dbg "`$Uri: <$Uri>"
 
    $R = Invoke-RestMethod -Uri $uri -Method Get   
    write-dbg "`$R count: <$($R.Length)>"
 
    if ($Full) {
       $R   | Select -expandproperty items  
    }
    else {
       foreach ($I in $( $R   | Select -expandproperty items)) {
          if ($I.Title) {
             $FirstWords = $I.Title + ' ' + $I.Content_Html
          }
          else {
 
             $FirstWords = $I.Content_Html
          }
          $FirstWords = Get-BsCleanText -DirtyText $FirstWords
       
          [PSCustomObject]@{
             DatePublished = $I.date_published
             FirstWords    = $FirstWords
          }
       }  
 
    }
 
    write-endfunction
    
    
 }
 