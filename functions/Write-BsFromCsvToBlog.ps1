function Write-BsFromCsvToBlog {
    <#
.SYNOPSIS
   xx
.EXAMPLE
   Write-BsFromCsvToBlog -Log c:\temp\BlogStuff\log.txt -CsvFile C:\powershell\data\tweetstestpack-ThuMay1.csv -BlogName mattypenny-test.micro.blog -draft $False

#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string] $Log,
        [Parameter(Mandatory = $True)][string] $CsvFile,
        [Parameter(Mandatory = $True)][string] $BlogName,
        $Draft = $True
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction

    [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
    [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)

    $SplatParams = @{
        BlogConfigUri = $BlogConfigUri
        BlogToken     = $BlogToken
    }
    
    $BlogConfig = Get-BsBlogConfig @SplatParams
    
    $RestMethodHeaders = @{
        "Authorization" = "Bearer $BlogToken"
    }

    $ConfigParams = @{
        BlogConfig        = $BlogConfig
        RestMethodHeaders = $RestMethodHeaders
        BlogName          = $BlogName
    }


    $LogFolder = Split-Path $Log -Parent
    if (-not (Test-Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
    }
   
    $TweetsBeingPosted = "$LogFolder/TweetsBeingPosted.csv"
    $Tweets = Import-Csv $CsvFile

    $Tweets = $Tweets | Out-GridView -Title "Select the tweets to post to $BlogName" -output multiple

    $Tweets | Export-Csv -path $TweetsBeingPosted -NoTypeInformation -Force 

    foreach ($Tweet in $Tweets) {

        [string]$TweetDate = $Tweet.datetime
        write-dbg "`$TweetDate: <$TweetDate>"
        $PostParams = @{
            PostTitle = $null
            PostDate  = $TweetDate
            PostBody  = $Tweet.Text
            Draft     = $Draft
        }
        Write-BsPostBodyToBlog @ConfigParams @PostParams
    }


   
    write-endfunction
   
   
}