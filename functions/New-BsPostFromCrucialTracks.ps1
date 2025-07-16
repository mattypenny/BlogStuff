function New-BsPostTextFromCrucialTracks {
    <#
.SYNOPSIS
   xx
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$CrucialTracksUri,
        [string]$Format = 'Short'
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction

    $CrucialTracksPosts = Get-BsCrucialTracksPosts -CrucialTracksUri $CrucialTracksUri -Format $Format

    $CrucialTracksPosts
   
    write-endfunction
   
   
}
function Get-BsCrucialTracksPosts {
    <#
.SYNOPSIS
   xx
.EXAMPLE
    . C:\Users\matty\OneDrive\powershell\Modules\BlogStuff\functions\New-BsPostFromCrucialTracks.ps1 ; New-BsPostTextFromCrucialTracks -CrucialTracksUri $feedurl
    Line1  :
Line2  : <title>Crucial Track for 12 May 2025</title>
Line3  : <link>https://app.crucialtracks.org/profile/mattypenny/20250512</link>
Line4  : <guid>https://app.crucialtracks.org/entries/338</guid>
Line5  : <pubDate>Mon, 12 May 2025 07:15:51 +0000</pubDate>
Line6  : <description><![CDATA[<p><em>"Henrietta Street" by The BeerMats</em></p>
Line7  : <p><a
         href="https://music.apple.com/us/album/henrietta-street/1570934588?i=1570934590"
         target="_blank">Listen on Apple Music</a></p>
Line8  : <p><audio controls><source src="https://audio-ssl.itunes.apple.com/itunes-assets/Au
         dioPreview115/v4/27/6c/56/276c56ec-86cd-b45e-0e09-34b36eb3fcd3/mzaf_177715791455151
         25768.plus.aac.p.m4a" type="audio/mp4">Your browser does not support the audio
         element.</audio></p>
Line9  : <p><em>How do you discover new music, and what’s the latest gem you’ve
         found?</em></p>
Line10 : <p>It's a mixture of the streaming service, Shazam-ing stuff, music magazines
         (through Libby)...and very occasionally seeing bands. This is from a band who I
         saw last month, who were fab</p>
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$CrucialTracksUri,
        [Parameter(Mandatory = $True)][string]$DownloadFolder = "C:\temp\BlogStuff\CrucialTracks",
        [Parameter(Mandatory = $True)][string]$BlogName = "mattypenny-test.micro.blog",
        [string]$Format
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction
   
    $Response = Invoke-WebRequest -Uri $CrucialTracksUri -UseBasicParsing
    $Content = $Response.Content

    $MarkdownText = @"
These are the posts from my [Crucial Tracks profile](https://app.crucialtracks.org/profile/mattypenny) for the last few days.
"@

    # split the content into the separate items
    [string[]]$Items = $Content -split "<item>"
    
    $Posts = foreach ($Item in $Items) {
        
        # skip the first item, which is the header info
        if ($Item -eq $Items[0]) {
            continue
        }

        # seperate the item into lines
        $Lines = $Item -split "`n"
  
        $DateString = $Lines[1] -replace ("<title>Crucial Track for ", "") -replace "</title>", ""
        write-dbg "`$Lines[1]: $($Lines[1]) `$DateString: <$DateString>"

        $Prompt = $Lines[8] -replace "<em>", "" -replace "</em>", "" -replace "<p>", "" -replace "</p>", "" 
        write-dbg "`$Lines[8]: $($Lines[8]) `$Prompt: <$Prompt>"

        $Song = $Lines[5] -replace "<description><!\[CDATA\[<p><em>", "" -replace "</em></p>", ""
        write-dbg "`$Lines[5]: $($Lines[5]) `$Song: <$Song>"

        if ($Format -eq 'Short') {
            $Link = $Lines[6].split('"')[1]
            $LocalImage = get-BSAppleImage -link $Lines[6].split('"')[1] -DownloadFolder $DownloadFolder
            $ImageNAme = [System.IO.Path]::GetFileName($LocalImage)
            $MbImage = Invoke-CopyBsComputerImageToBlog -PhotoFolder $DownloadFolder -PhotoName $ImageName -BlogName $BlogName
            $LinkText = get-BSAppleHtml -Link $Link -Image $Image -Format $Format
        }
        else {
            $Link = $Lines[6].split('"')[1]
            write-dbg "`$Lines[6]: $($Lines[6]) `$Song: <$Link>"

            $LinkText = @"
{{< apple-music url="$Link" >}}


<a href="$Link" target="_blank">$Song on Apple Music</a>
"@
        }

        $AppleHtml = get-BsAppleHtml -Link $Link -Image $Image -Format $Format

        $Comment = ""
        for ($i = 9; $i -lt $lines.Count; $i++) {
            if ($Lines[$i] -like "*View*Crucial Tracks profile*") {
                break
            }

            $CommentLine = $Lines[$i] -replace "<p>", "" -replace "</p>"

            if ($CommentLine) {
                $Comment = @"
$Comment
$CommentLine

"@
            }
        }
        write-dbg "`$Lines[9]: $($Lines[9]) `$Song: <$Comment>"


        $MarkdownText = @"
$MarkdownText
### $DateString - _${Prompt}_


$Song


$Comment



"@

        <#
        [PSCustomObject]@{
            DateString = $DateString
            Prompt     = $Prompt
            Song       = $Song
            Link       = $Link
            Comment    = $Comment
            Text       = $MarkdownText
        }
        #>

        
    }

   

    write-endfunction
   
    # $Posts
    $MarkdownText = $MarkdownText -replace "’", "'"
    $MarkdownText
   
}

function get-BSAppleImage {
    <#
.SYNOPSIS
   xx
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$TrackUrl,
        $Folder = 'C:\temp\BlogStuff\AppleImages',
        [Parameter(Mandatory = $True)][string]$FileName
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction

    write-dbg "`$Folder: <$Folder>"

    if (Test-Path -Path $Folder) {
        write-dbg "`$Folder exists"
    }
    else {
        mkdir $Folder | Out-Null
    }

    $OutFile = Join-Path -Path $Folder -ChildPath $FileName

    # Assuming $TrackUrl is in this format: https://music.apple.com/us/album/take-me-home-country-roads/1440919985?i=1440920253
    write-dbg "`$TrackUrl: <$TrackUrl>"
    
    # Extract the track ID from the URL
    $trackId = $TrackUrl.split('/')[6] + '?'
    $trackId = $TrackId.split('?')[0]

    # $trackId should look like this: "1440919985" # Replace with your track's ID
    write-dbg "`$TrackId: <$TrackId>"

    $region = "us" # Change for your country's Apple Music store

    $url = "https://itunes.apple.com/$region/lookup?id=$trackId"

    $response = Invoke-RestMethod -Uri $url

    $albumArtUrl = $response.results[0].artworkUrl100

    invoke-webrequest -Uri $albumArtUrl -OutFile $OutFile -UseBasicParsing
   
    write-endfunction
   
   
}

function get-BSAppleHtml {
    <#
.SYNOPSIS
   xx
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$Link
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction

    write-dbg "`$Link: <$Link>"
   
   
    write-endfunction
   
   
}

function New-BsWeeklyPostFromCrucialTracks {
    <#
.SYNOPSIS
    xx
.NOTES
    It needs to looks like this, but with the song title as a link:

    <div style="overflow: auto; margin-bottom: 20px;">
  <img src="https://mattypenny-test.micro.blog/uploads/2025/toots.jpg" width="100" height="100" alt="Toots and the Maytals album art" style="float: left; margin-right: 15px;">
  <div style="overflow: hidden;">
    <p style="margin-top: 0; margin-bottom: 0;"><strong><em>Share a song that feels like coming home after a long trip.</em></strong></p>
    <p style="margin-top: 5px;">Toots and the Maytals - Take Me Home Country Roads</p>
  </div>
</div>

<div style="overflow: auto;">
  <img src="https://mattypenny-test.micro.blog/uploads/2025/toots.jpg" width="100" height="100" alt="Album art for a dream-like song" style="float: left; margin-right: 15px;">
  <div style="overflow: hidden;">
    <p style="margin-top: 0; margin-bottom: 0;">What song makes you feel like you're in a dream?</p>
    <p style="margin-top: 5px;">There are a couple of dream songs I really like - Spancil Hill, Christy Moore's Delirium Tremens - but this is maybe my favourite. According to the streaming service it was the song I played most a couple of years back</p>
  </div>
</div>
#>
    [CmdletBinding()]
    param (
   
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction
   
   
    write-endfunction
   
   
}