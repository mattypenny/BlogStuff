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
   
    $Response = Invoke-WebRequest -Uri $CrucialTracksUri -UseBasicParsing
    $Content = $Response.Content

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
    
    <# Extract:
    - the title, 
    - the link, - 
    - the text in the <em> tags that immediately follows 'CDATA' as 'Song', 
    - the other text in the <em> tags as 'prompt'
    #>
    $Posts = foreach ($Item in $Items) {
        if ($Item -match "<title>(.*?)</title>") {
            $Title = $matches[1]
        }
        if ($Item -match "<link>(.*?)</link>") {
            $Link = $matches[1]
        }
        # Extract the song title from the CDATA section
        if ($Item -match "<!\[CDATA\[<p><em>(.*?)</em></p>") {
            $Song = $matches[1]
        }
        [PSCustomObject]@{
            Title  = $Title
            Link   = $Link
            Song   = $Song
            Prompt = $Prompt
        }
    }

   

    write-endfunction
   
    $Posts
   
}