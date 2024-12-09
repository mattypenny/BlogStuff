import-module -force SpotiShell
function New-BsBlogPostFromSpotifyPlaylist {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [string]$BlogToken = $(Get-BsParameter -parameter BsBlogToken),
      [string]$BlogName = $(Get-BsParameter -parameter BsBlogName),
      [string]$PlaylistName = $(Get-BsParameter -parameter BsPlaylistName),
      [string]$BlogConfigUri = $(Get-BsParameter -parameter BsBlogConfigUri),
      [string]$SpotifyWork = $(Get-BsParameter -parameter BsSpotifyWork),
      [string]$BodyPath = $(Get-BsParameter -parameter BsBodyPath),
      [string]$ImageFolderPath = $(Get-BsParameter -parameter BsImageFolderPath),

      $Since = $(get-date).adddays(-14)
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction


   $Songs = Get-BsSpotifyPlaylistSongs -Since $Since -PlaylistName $PlaylistName
   
   $BlogConfig = Get-BsBlogConfig -BlogConfigUri $BlogConfigUri -BlogToken $BlogToken

   $Params = @{
      Songs           = $Songs
      BlogConfig      = $BlogConfig
      BodyPath        = $BlogPath
      ImageFolderPath = $ImageFolderPath
   }
   [string]$PostBody = Get-BSPostBody @Params
   
   
   Write-Output $PostBody
   
   write-endfunction
   
}

function Write-BsPostBodyToBlog {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)] $BlogConfig,
      [Parameter(Mandatory = $True)] $RestMethodHeaders,
      [Parameter(Mandatory = $True)][string] $BlogName,
      [Parameter(Mandatory = $True)][string] $PostTitle,
      [Parameter(Mandatory = $True)][string]  $PostBody,
      $Draft = $True
      # CrossPostToBlueSky = $False
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   <#
    $Destination = $BlogConfig | 
   Select-Object -ExpandProperty destination |
   Where-Object name -EQ $BlogName

   [string]$MpDestination = $Destination.Uid
   $MpDestination = [System.Web.HttpUtility]::UrlEncode($MpDestination)

   $Uri = "${mediaEndpoint}?mp-destination=$MpDestination" 

   write-dbg "`$BlogName: <$BlogName>"
   write-dbg "`$Uri: <$Uri>"
   #>

   

$Destination = $BlogConfig | 
                 Select-Object -ExpandProperty destination |
                 Where-Object name -EQ $BlogName

$Destination
write-dbg "`$Destination: <$Destination>"

 [string]$MpDestination = $Destination.Uid
 write-dbg "`$MpDestination: <$MpDestination>"

   $MpDestination = 
              [System.Web.HttpUtility]::UrlEncode($MpDestination)


$Uri ="https://micro.blog?mp-destination=$MpDestination"


$body = "h=entry&content=$([System.Web.HttpUtility]::UrlEncode('a hardcoded hello'))"



# $Uri ="https://micro.blog/micropub?mp-destination=$MpDestination"

$response = Invoke-RestMethod -Uri $uri -Method Post -Headers 
              $headers -Body $body

   
   
   write-endfunction
   
   $response
   
}

function Get-BsSpotifyPlaylistSongs {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string]$PlaylistName,
      $Since = $(get-date).adddays(-14)
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   $PlaylistId = Get-BsSpotifyPlaylistId -PlaylistName $PlaylistName
   
   $PlayListItems = Get-PlaylistItems $PlaylistId

   write-dbg "`$PlayListItems count: <$($PlayListItems.Length)>"

   $PlayListItems = $PlayListItems |
   Where-Object added_at -gt $Since
   Sort-Object -property added_at 
    
   write-dbg "`$PlayListItems count: <$($PlayListItems.Length)>"
   foreach ($I in $PlayListItems) {
      $Addedat = $I.added_at

      $Tracks = $I | Select-Object -ExpandProperty Track
      foreach ($T in $Tracks) {
         $TrackName = $T.Name

         # There does only seem to be on URL per track
         $External_URL = $T | 
         Select-Object -ExpandProperty External_Urls |
         Select-Object -First 1

         $Album = $T |
         Select-Object -ExpandProperty Album |
         Select-Object -first 1  # only expecting 1, but...

         $FirstImage = $Album |
         Select-Object -ExpandProperty images |
         Sort-Object -Property Width |
         Select-Object -Last 1
            
         $Artists = $T |
         Select-Object -ExpandProperty Artists

         $ArtistString = ""
         foreach ($A in $Artists) {
            $Name = $A.name
            $ArtistString = "$Artiststring,$Name" 
         }
         $ArtistString = $ArtistString.TrimStart(',')
         [PSCustomObject]@{
            AddedAt   = $I.Added_At
            Artist    = $ArtistString
            TrackName = $T.NAme
            MusicURL  = $External_URL.Spotify
            Album     = $Album.Name
            ImageURL  = $FirstImage.url

         }
      }
   }
   
}

function Get-BsSpotifyPlaylistId {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string]$PlaylistName
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   $Playlist = Get-CurrentUserPlaylists | Where-Object name -eq $PlaylistName
   
   $Id = $Playlist.Id

   write-endfunction

   return $Id
   
   
}

function New-BsBlogPostFromSpotifySongs {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      $Songs
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   
   write-endfunction
   
   
}

function Get-BsPostBody {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)]$BlogConfig,
      [Parameter(Mandatory = $True)]$RestMethodHeaders,
      [Parameter(Mandatory = $True)]$BlogName,
      [Parameter(Mandatory = $True)]$Songs,
      [Parameter(Mandatory = $True)][string]$BodyFile,
      [Parameter(Mandatory = $True)][string]$ImageFolderPath

   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   write-dbg "`$Songs count: <$($Songs.Length)>"
   $PostBody = ""
   
   foreach ($S in $Songs) {
      [string]$Artist = $S.Artist
      [string]$TrackName = $S.TrackNAme
      [string]$MusicURL = $S.MusicURL
      [string]$Album = $S.Album
      [string]$ImageURL = $S.ImageURL

      write-dbg "`$TrackName: <$TrackName> `$Artist: <$Artist> `$ImageUrl: <$ImageUrl>"
   

      $Params = @{
         ImageFolderPath = $ImageFolderPath 
         ImageURL        = $ImageURL 
         Album           = $Album 
         Artist          = $Artist
      }
      $SpotifyImage = Copy-BsSpotifyImageToComputer @Params

      $Params = @{
         BlogName          = $BlogName
         BlogConfig        = $BlogConfig
         RestMethodHeaders = $RestMethodHeaders
      }

      $BlogImage = Copy-BsComputerImageToBlog -imagePath $SpotifyImage @Params


      <#
      <p>
<img src="/tmp/spotify/ab67616d0000b273efd23057f80e32da5b1c0345.jpeg" alt="Smiley face" style="float:left;width:42px;height:42px;margin-right:10px">     <a href="https://open.spotify.com/track/22QMzoI3O7yNnttjKq9SfF">Draggin' the Line - Tommy James & The Shondells]</a> - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx sdsuhdushdushdushdu
</p>
      #> 
      $PostBody = @"
$PostBody
<p>
   <img 
      src="$BlogImage" 
      alt="Cover of the Spotify 'album' - $Album"
      style="float:left;width:42px;height:42px;margin-right:10px">
   <a href=
      "$MusicURL">
      $TrackName - $Artist
   </a> 
   - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx sdsuhdushdushdushdu
</p>
"@

   }
   
   Write-BsPostBodyToFile -BodyFile $BodyFile -PostBody $PostBody 
   
   write-endfunction

   $PostBody
   
   
}

function Copy-BsSpotifyImageToComputer {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string] $ImageFolderPath ,
      [Parameter(Mandatory = $True)][string] $ImageURL ,
      [Parameter(Mandatory = $True)][string] $Album ,
      [Parameter(Mandatory = $True)][string] $Artist
   
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   $Extension = [System.io.path]::GetExtension( $ImageURL)
   $OutFile = Join-Path $ImageFolderPath -ChildPath "$Artist - $Album$Extension"
   Invoke-WebRequest -uri $ImageURL -outfile $OutFile
   
   write-endfunction

   $Outfile
   
   
}
function Write-BsPostBodyToFile {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string]$PostBody,
      [Parameter(Mandatory = $True)][string]$BodyFile  
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   Set-Content -path $BodyFile -Value $PostBody
   
   write-endfunction
   
   
}

function Copy-BsComputerImageToBlog {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)]$BlogConfig,
      [Parameter(Mandatory = $True)][string]$BlogName,

      [Parameter(Mandatory = $True)]$RestMethodHeaders,
      [Parameter(Mandatory = $True)][string]$imagePath
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   write-dbg "`$BlogToken count: <$($BlogToken.Length)>"
   
   [string]$mediaEndpoint = $BlogConfig."media-endpoint"

   $Destination = $BlogConfig | 
   Select-Object -ExpandProperty destination |
   Where-Object name -EQ $BlogName

   [string]$MpDestination = $Destination.Uid
   $MpDestination = [System.Web.HttpUtility]::UrlEncode($MpDestination)

   $Uri = "${mediaEndpoint}?mp-destination=$MpDestination" 

   write-dbg "`$BlogName: <$BlogName>"
   write-dbg "`$Uri: <$Uri>"

   $form = @{
      file = Get-Item $imagePath
   }
   $uploadResponse = Invoke-RestMethod -Uri $Uri -Method Post -Headers $RestMethodHeaders -Form $form
   $imageUrl = $uploadResponse.Url
   write-endfunction

   return $imageUrl
   
   
}

function Get-BsBlogConfig {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string] $BlogConfigUri,
      [Parameter(Mandatory = $True)][string]$BlogToken
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   write-dbg "`$BlogToken count: <$($BlogToken.Length)>"
   write-dbg "`$BlogConfigUri: <$BlogConfigUri>"
   
   $headers = @{
      "Authorization" = "Bearer $BlogToken"
   }
   $BlogConfig = Invoke-RestMethod -Uri $BlogConfigUri -Headers $headers
   
   write-dbg "`$BlogConfig count: <$($BlogConfig.Length)>"
   write-endfunction
   
   return $BlogConfig
   
}

function write-dbg {
   <#
   .SYNOPSIS
      xx
   #>
   [CmdletBinding()]
   param (
      $DebugText 
   )
      
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   write-debug $DebugText
      
}
   

function write-startfunction {
   <#
   .SYNOPSIS
      xx
   #>
   [CmdletBinding()]
   param (
      
   )
      
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
      
      
      
}
   
function write-endfunction {
   <#
   .SYNOPSIS
      xx
   #>
   [CmdletBinding()]
   param (
      
   )
      
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
      
      
      
}

function Get-BsParameter {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      $ParameterFile = "$PSParametersFolder/GeneralParameters.csv",
      [Parameter(Mandatory = $True)][string]$Parameter

   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction
   
   $ParameterRow = $(import-csv $PSParametersFolder/GeneralParameters.csv | 
      Where-Object Parameter -eq $Parameter)

   $Value = $ParameterRow.Value
   
   write-endfunction

   return $Value
   
}

function Get-BsPosts {
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

function Get-BsCleanText {
   <#
.SYNOPSIS
   xx
#>
   [CmdletBinding()]
   param (
      [Parameter(Mandatory = $True)][string] $DirtyText
   )
   
   $DebugPreference = $PSCmdlet.GetVariableValue('DebugPreference')
   
   write-startfunction

   # Use a regex to replace HTML tags with nothing
   $CleanText = $DirtyText -replace '<[^>]*>', ''

   # Replace common HTML entities with their corresponding characters
   $CleanText = $CleanText -replace '&rsquo;', "'"
   $CleanText = $CleanText -replace '&lsquo;', "'"
   $CleanText = $CleanText -replace '&rdquo;', '"'
   $CleanText = $CleanText -replace '&ldquo;', '"'
   $CleanText = $CleanText -replace '&ndash;', '-'
   $CleanText = $CleanText -replace '&mdash;', '-'
   $CleanText = $CleanText -replace '&amp;', '&'
   $CleanText = $CleanText -replace '&lt;', '<'
   $CleanText = $CleanText -replace '&gt;', '>'
   $CleanText = $CleanText -replace '&nbsp;', ' '
   # Add more replacements as needed

   return $CleanText
}