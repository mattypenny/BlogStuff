
Describe "Write-BsPostBodyToBlog" {
    BeforeAll {
        Import-Module BlogStuff -force 


        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
        [string]$BlogName = $(Get-BsParameter -parameter BsTestBlogName)
        [string]$PlaylistName = $(Get-BsParameter -parameter BsTestPlaylistName)
        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)
        [string]$SpotifyWork = $(Get-BsParameter -parameter BsTestSpotifyWork)
        [string]$BodyPath = $(Get-BsParameter -parameter BsTestBodyPath)
        [string]$ImageFolderPath = $(Get-BsParameter -parameter BsTestImageFolderPath)

        [string]$PostTitle = "Test test $(get-date)"
        [string]$PostBody = "Postbody test"
  
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
            PostTitle         = $PostTitle
            PostBody          = $PostBody
            Draft             = $true
            # CrossPostToBlueSky = $False
            # CrossPostToMastodon = $False
        }

        $Response = Write-BsPostBodyToBlog @SplatParams


        

    }

    It "posts to the blog" {
        $False |  Should -Be $True
    }

    It "posts to the blog as a draft" {
        $False |  Should -Be $True
    }

    AfterAll {
        write-host -foreground Red "needs to delete the post"
    }
}
