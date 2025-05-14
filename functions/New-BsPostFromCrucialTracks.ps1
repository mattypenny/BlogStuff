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
    <#
$Content looks like this:
<?xml version="1.0" encoding="UTF-8"?><rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom"><channel><title>mattypenny's Crucial Tracks</title><link>https://app.crucialtracks.org/profile/mattypenny</link><description>Journal entries from mattypenny on Crucial Tracks</description><atom:link href="https://app.crucialtracks.org/profile/mattypenny/feed" rel="self" type="application/rss+xml" /><language>en-US</language><lastBuildDate>Mon, 12 May 2025 07:15:51 +0000</lastBuildDate><item><title>Crucial Track for 12 May 2025</title><link>https://app.crucialtracks.org/profile/mattypenny/20250512</link><guid>https://app.crucialtracks.org/entries/338</guid><pubDate>Mon, 12 May 2025 07:15:51 +0000</pubDate><description><![CDATA[<p><em>"Henrietta Street" by The BeerMats</em></p>
<p><a href="https://music.apple.com/us/album/henrietta-street/1570934588?i=1570934590" target="_blank">Listen on Apple Music</a></p>
<p><audio controls><source src="https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/27/6c/56/276c56ec-86cd-b45e-0e09-34b36eb3fcd3/mzaf_17771579145515125768.plus.aac.p.m4a" type="audio/mp4">Your browser does not support the audio element.</audio></p>
<p><em>How do you discover new music, and what’s the latest gem you’ve found?</em></p>
<p>It's a mixture of the streaming service, Shazam-ing stuff, music magazines (through Libby)...and very occasionally seeing bands. This is from a band who I saw last month, who were fab</p>

<p><a href="https://app.crucialtracks.org/profile/mattypenny">View mattypenny's Crucial Tracks profile</a></p>
]]></description></item><item><title>Crucial Track for 11 May 2025</title><link>https://app.crucialtracks.org/profile/mattypenny/20250511</link><guid>https://app.crucialtracks.org/entries/320</guid><pubDate>Sun, 11 May 2025 07:40:45 +0000</pubDate><description><![CDATA[<p><em>"Blue Is the Colour" by Chelsea Football Club</em></p>
<p><a href="https://music.apple.com/us/album/blue-is-the-colour/1490605632?i=1490605634" target="_blank">Listen on Apple Music</a></p>
<p><audio controls><source src="https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview126/v4/83/e4/b0/83e4b042-0d82-83e5-87f0-e790d96756d5/mzaf_893233275045767455.plus.aac.p.m4a" type="audio/mp4">Your browser does not support the audio element.</audio></p>
<p><em>What is a song that feels like home to you?</em></p>
<p>This feels like home both because it was the first record I had when I was a kid, and because I hear it at Home games</p>

<p><img src="http://app.crucialtracks.org/storage/entries/320/images/1746949245_6820547dc7261.jpg" alt="Entry image" /></p>



#>

    # split the content into the separate items
    $Items = $Content -split "<item>"
    
    $Posts = foreach ($Item in $Items) {
        
        # skip the first item, which is the header info
        if ($Item -eq $Items[0]) {
            continue
        }

        # seperate the item into lines

        $Lines = $Item -split "`n"

        $Line1 = $Lines[0]
        $Line2 = $Lines[1]
        $Line3 = $Lines[2]
        $Line4 = $Lines[3]

        $Line5 = $Lines[4]
        $Line6 = $Lines[5]

        $Line7 = $Lines[6]

        $Line8 = $Lines[7]

        $Line9 = $Lines[8]
        $Line10 = $Lines[9]
        $Line11 = $Lines[10]

        <#

        This is where I want to get to:

        08 May 2025 - <i>What’s your favorite love song, and why??"</i>

"A Rainy Night In Soho" by The Pogues

{{< apple-music url="https://music.apple.com/us/album/a-rainy-night-in-soho/189236068?i=189236584" >}}

<a href="https://music.apple.com/us/album/a-rainy-night-in-soho/189236068?i=189236584" target="_blank">"A Rainy Night In Soho" by The Pogues on Apple Music</a>

[mattypenny's crucial tracks](https://app.crucialtracks.org/profile/mattypenny)
        #>
        
        $DateString = $Line2 -replace ("<title>Crucial Track for ", "") -replace "</title>", ""
        $Prompt = $Line9 -replace "<em>", "" -replace "</em>", "" -replace "<p>", "" -replace "</p>", "" 
        $Song = $Line6 -replace "<description><!\[CDATA\[<p><em>", "" -replace "</em></p>", ""
        $Link = $Line7.split('"')[1]
        $Comment = $Line10 -replace "<p>", "" -replace "</p>"

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

            Line1      = $Line1
            Line2      = $Line2
            Line3      = $Line3
            Line4      = $Line4
            Line5      = $Line5
            Line6      = $Line6
            Line7      = $Line7
            Line8      = $Line8
            Line9      = $Line9
            Line10     = $Line10
        }
        #>

        
    }

   

    write-endfunction
   
    # $Posts
    $MarkdownText = $MarkdownText -replace "’", "'"
    $MarkdownText
   
}