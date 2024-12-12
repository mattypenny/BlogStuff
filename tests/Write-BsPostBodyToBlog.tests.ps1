
Describe "Write-BsPostBodyToBlog" {
    BeforeAll {
        Import-Module BlogStuff -force 


        [string]$BlogToken = $(Get-BsParameter -parameter BsTestBlogToken)
        [string]$BlogName = $(Get-BsParameter -parameter BsTestBlogName)
        [string]$BlogConfigUri = $(Get-BsParameter -parameter BsTestBlogConfigUri)

        [string]$PostTitle = "Test test $(get-date)"
        [string]$PostBody = "Postbody test $(get-date)"
  
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

        $Response
        

    }

    It "returns the URL of the post" {
        $Response | Should -HaveCount 1

        $Actualurl= $Response.url

        $ExpectedUrl = 'https://' +
            $BlogName + '/' +
            $(get-date).Year + '/' +
            $(get-date).Month + '/' +
            $(get-date).Day + '/' +
            "*"
    
        $ActualUrl | Should -BeLike $ExpectedUrl
    }

    It "posts to the blog" {
        start-sleep -Seconds 5
        $Posts = get-BsPosts -BlogShortName test -full
        $LastPost = $Posts | Sort-Object -Property date_published | Select-Object -Last 1

        $LastPostBody = $LastPost.Content_Html

        $LastPostBody | Should -BeLike "*$PostBody*"

    }

    It "posts to the blog as a draft" {
        $False |  Should -Be $True
    }

    AfterAll {
        write-host -foreground Red "needs to delete the post"
    }
}
