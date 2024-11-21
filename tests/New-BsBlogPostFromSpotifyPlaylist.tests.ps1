<#
Describe "New-BsBlogPostFromSpotifySongs" {

    BeforeAll {

        Import-Module BlogStuff -force
        $Csv = @"
"AddedAt","Artist","TrackName","MusicURL","Album","ImageURL"
"10/22/2024 8:51:11 AM","Tommy James & The Shondells","Draggin' the Line","https://open.spotify.com/track/22QMzoI3O7yNnttjKq9SfF","Celebration: The Complete Roulette Recordings 1966-1973","https://i.scdn.co/image/ab67616d0000b273649b753eec1510732d577735"
"10/22/2024 :58:14 AM","Kip Tyler","Eternity","https://open.spotify.com/track/4a7YOxLgUP4PuW4WuM1yO1","Ooh Yeah Baby","https://i.scdn.co/image/ab67616d0000b273b0f358fa8c34324f4f65f9b7"
"10/22/2024 12:25:03 AM","Sue Moreno","Feel the Love","https://open.spotify.com/track/3fD3Cca1Eu5UlB1PTR90dI","Feel the Love","https://i.scdn.co/image/ab67616d0000b2739a040796b4c75dcef603a7d0"
"10/22/2024 12:37:53 AM","Susan Cadogan","Fever","https://open.spotify.com/track/4vfexGvMGGnU6lPLtvSzZl","Reggae For Fathers And Daughters","https://i.scdn.co/image/ab67616d0000b273d44719966f9c354ea0e2cfb2"
"10/22/2024 12:40:51 AM","The Lee Thompson Ska Orchestra,Bitty McLean","Fu Man Chu","https://open.spotify.com/track/2qnu1ZAhbANgEKIdHvjjnL","The Benevolence of Sister Mary Ignatius","https://i.scdn.co/image/ab67616d0000b273b18991226cabf4eb91a62dec"
"10/22/2024 12:45:25 AM","Robert Gordon","Fire","https://open.spotify.com/track/3FWeBOSEq9fWc6jhNm695s","Fresh Fish Special (with Link Wray)","https://i.scdn.co/image/ab67616d0000b273573dd0e738118de5d93d75f7"
"10/22/2024 18:10:10 PM","The Soul Brothers","Freedom Sounds","https://open.spotify.com/track/6Rkoc4hjT3rD7SZN5d5AMj","Reggae For Fathers And Daughters","https://i.scdn.co/image/ab67616d0000b273d44719966f9c354ea0e2cfb2"
"10/22/2024 18:13:58 PM","The Dubliners,Luke Kelly","A Gentleman Soldier","https://open.spotify.com/track/4N4nND4rma5DjcOIrxDa93","Definitive Pub Songs Collection","https://i.scdn.co/image/ab67616d0000b273bf0380fdf64ae46fd7b2e629"
"@

        $Songs = $csv | ConvertFrom-Csv

        $WorkingFolder = Get-BsParameter -Name SpotifyWork

        if (!(test-path $WorkingFolder)) {
        New-Item  -ItemType Directory -path  $WorkingFolder
        }

        $BodyFolder = "$WorkingFolder/Body"
        if (!(test-path $BodyFolder)) {
        New-Item  -ItemType Directory -path  $BodyFolder
        }

        $BodyPath = "$bodyFolder/Test1.md"
        remove-item $BodyPath

        $imagesFolder = "$WorkingFolder/images"
        if (!(test-path $imagesFolder)) {
        New-Item  -ItemType Directory -path  $imagesFolder
        }

        $PostBody = Get-BsPostBody -songs $Songs -BodyPath $BodyPath -ImageFolderPath $imagesFolder

        Write-Host $PostBody
        
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
#>
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

        write-dbg "About to delete `$BlogImageUrl: <$BlogImageUrl>"
        write-dbg "But having a snooze first"
        start-sleep -Seconds 2

        # Send the HTTP POST request
        $response = Invoke-RestMethod -Uri $BlogimageUrl -Method Delete -Headers $headers

        # Output the response
        $response

    }

}