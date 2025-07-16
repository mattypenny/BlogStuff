Describe "Get-BsAppleImage Tests" {
    BeforeAll {
        Import-Module -Name BlogStuff -Force

        $Folder = "C:\temp\BlogStuff\AppleImages\"
        $ExpectedFileName = "Emerald City - Bethany Eve - test copy.jpg"

    }

    Context "gets an image from Apple Music" {
        It "Should download an image to the specified path" {
            get-BSAppleImage -TrackUrl https://music.apple.com/us/album/emerald-city/1762406166?i=1762406167 -FileName $ExpectedFileName -Folder $Folder

            $(Get-ChildItem $Folder\$ExpectedFileName) | Should -HaveCount 1

            remove-item $Folder\$ExpectedFileName -Force
        }

    }

    Context "creates the target if it does not exist" {
    
        It "Should create the target folder if it does not exist" {
            $NewFolder = "C:\temp\BlogStuff\AppleImages\NewFolder\"
            if (Test-Path -Path $Folder) {
                Remove-Item -Path $Folder -Recurse -Force
            }

            get-BSAppleImage -TrackUrl https://music.apple.com/us/album/emerald-city/1762406166?i=1762406167 -FileName $ExpectedFileName -Folder $NewFolder



            $(Get-ChildItem $NewFolder) | Should -HaveCount 1
            $(Get-ChildItem $NewFolder\$ExpectedFileName) | Should -HaveCount 1
            Remove-Item -Path $NewFolder -Recurse -Force
        }
    }
}