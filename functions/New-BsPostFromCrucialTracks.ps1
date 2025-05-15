function New-BsPostTextFromCrucialTracks {
    <#
.SYNOPSIS
   xx
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $True)][string]$CrucialTracksUri
    )
   
    $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
    write-startfunction

    $CrucialTracksPosts = Get-BsCrucialTracksPosts -CrucialTracksUri $CrucialTracksUri

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
        [Parameter(Mandatory = $True)][string]$CrucialTracksUri
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

        $Link = $Lines[6].split('"')[1]
        write-dbg "`$Lines[6]: $($Lines[6]) `$Song: <$Link>"

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


{{< apple-music url="$Link" >}}


<a href="$Link" target="_blank">$Song on Apple Music</a>

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