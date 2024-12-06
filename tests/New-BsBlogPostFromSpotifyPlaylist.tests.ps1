Describe "Get-BsPostBody" {

    BeforeAll {

        Import-Module BlogStuff -force
        $Csv = @"
"AddedAt","Artist","TrackName","MusicURL","Album","ImageURL"
"10/22/2024 12:25:03 AM","Sue Moreno","Feel the Love","https://open.spotify.com/track/3fD3Cca1Eu5UlB1PTR90dI","Feel the Love","https://i.scdn.co/image/ab67616d0000b2739a040796b4c75dcef603a7d0"
"10/22/2024 12:37:53 AM","Susan Cadogan","Fever","https://open.spotify.com/track/4vfexGvMGGnU6lPLtvSzZl","Reggae For Fathers And Daughters","https://i.scdn.co/image/ab67616d0000b273d44719966f9c354ea0e2cfb2"
"@

        $Songs = $csv | ConvertFrom-Csv


        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
        [string]$BlogName = $(Get-BsParameter -parameter BsTestBlogName)
        [string]$PlaylistName = $(Get-BsParameter -parameter BsTestPlaylistName)
        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)
        [string]$SpotifyWork = $(Get-BsParameter -parameter BsTestSpotifyWork)
        [string]$BodyPath = $(Get-BsParameter -parameter BsTestBodyPath)
        [string]$ImageFolderPath = $(Get-BsParameter -parameter BsTestImageFolderPath)

        $Since = $(get-date).adddays(-14)
  

        if (!(test-path $SpotifyWork)) {
            New-Item  -ItemType Directory -path  $SpotifyWork
        }

        if (!(test-path $BodyPAth)) {
            New-Item  -ItemType Directory -path  $BodyPAth
        }

        $BodyFile = "$bodyPAth/Test1.md"
        if (test-path $BodyFile) {
            remove-item $BodyFile
        }

        if (!(test-path $imageFolderPath)) {
            New-Item  -ItemType Directory -path  $imageFolderPath
        }

        $SplatParams = @{
            BlogConfigUri = $BlogConfigUri
            BlogToken     = $BlogToken
        }
        
        $BlogConfig = Get-BsBlogConfig @SplatParams
        
        $RestMethodHeaders = @{
            "Authorization" = "Bearer $BlogToken"
        }
        $SplatParams = @{
            BlogConfig        = $BlogConfig
            RestMethodHeaders = $RestMethodHeaders
            BlogName          = $BlogName
            Songs             = $Songs
            BodyFile          = $BodyFile
            ImageFolderPath   = $ImageFolderPath
        }

        $PostBody = Get-BsPostBody @SplatParams


        write-dbg "`$PostBody: <$PostBody>"
        
    }

    It "must create a body" {
        $PostBody.length | Should -BeGreaterThan 10
        write-host $PostBody
    }

    It "must write to $BodyPath" {
        $BodyFile = get-childitem $BodyPath

        $LAstWriteTime = $BodyFile.LastWriteTime
        $Length = $BodyFile.Length

        $LAstWriteTime | Should -BeGreaterThan $(get-date).AddMinutes(-1)
        $Length | Should -BeGreaterThan 100
    }
}


describe "Get-BsSpotifyPlaylistId" {

    BeforeAll {
        ipmo -force BlogStuff

        [string]$PlaylistName = $(Get-BsParameter -parameter BsTestPlaylistName2)
        
        $PlaylistId = Get-BsSpotifyPlaylistId -PlaylistName $PlaylistName

    }

    It "must return a playlist id <PlayListId> for playlist <PlayListName>" {

        $PlaylistId.length | Should -BeGreaterThan 10 
    }


}
describe "Get-BsSpotifyPlaylistSongs " {
    BeforeAll {
        ipmo -force BlogStuff

        [string]$PlaylistName = $(Get-BsParameter -parameter BsTestPlaylistName2)
        
        $Songs = Get-BsSpotifyPlaylistSongs -PlaylistName $PlaylistName -Since 100000

    }

    It "shoould retrieve songs" {
        $Songs.length | Should -BeGreaterThan 10
    }
}
Describe "Get-BsBlogConfig" {

    BeforeAll {
        ipmo -force BlogStuff

        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)
      
        $BlogConfig = Get-BsBlogConfig -BlogConfigUri $BlogConfigUri -BlogToken $BlogToken

    }

    It "should return three rows, one for tweets, one for test and one vanilla" {
        $Destination = $BlogConfig | Select-Object -ExpandProperty Destination
        $Destination | Should -HaveCount 3
        $Destination | Where-Object Name -like "*tweet*" | Should -HaveCount 1
        $Destination | Where-Object Name -like "*test*" | Should -HaveCount 1
        $Destination | 
        Where-Object Name -notlike "*tweet*" | 
        Where-Object Name -notlike "*test*" | 
        Should -HaveCount 1

    }

}
Describe "Copy-BsComputerImageToBlog" {

    BeforeAll {
        ipmo -force BlogStuff

        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)
        [string]$BlogName = $(Get-BsParameter -parameter BsTestBlogName)
      
        $BlogConfig = Get-BsBlogConfig -BlogConfigUri $BlogConfigUri -BlogToken $BlogToken

        $Image = '/home/matty/test/spotify/images/Ann-Margret,Elvis Presley - Let Me Entertain You'
        
        $headers = @{
            "Authorization" = "Bearer $BlogToken"
        }
        $Params = @{
            RestMethodHeaders = $headers
            ImagePath         = $Image
            BlogConfig        = $BlogConfig
            BlogName          = $BlogName
        }
        $BlogIMageURl = Copy-BsComputerImageToBlog @Params

    }

    It "returns a valid URI - <BlogImageUrl>" {
        $BlogIMageURl | Should -BeLike "http*"
    }

    AfterAll {

        # write-dbg "About to delete `$BlogImageUrl: <$BlogImageUrl>"
        # write-dbg "But having a snooze first"
        #start-sleep -Seconds 2

        # Send the HTTP POST request
        # $response = Invoke-RestMethod -Uri $BlogimageUrl -Method Delete -Headers $headers

        # Output the response
        $response

    }

}