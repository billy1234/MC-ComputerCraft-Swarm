Get-Content .env | ForEach-Object {
  $name, $value = $_.split('=')
  set-content env:\$name $value
}

$ErrorActionPreference = "Stop"
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { return $true }


function Publish-File {
  param (
    [string]$URIBase,
    [string]$ServerBase,
    [string]$FileName,
    [string]$LocalFile
  )
    # Create FTP Rquest Object
    $FTPRequest = [System.Net.FtpWebRequest]::Create( [system.URI]($URIBase + '/' + $ServerBase + '/' + $FileName))
    $FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
    $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $FTPRequest.Credentials = new-object System.Net.NetworkCredential($ENV:USERNAME, $ENV:PASSWORD)
    $FTPRequest.UseBinary = $true
    $FTPRequest.UsePassive = $true
    $FTPRequest.EnableSsl = $true;

   # Read the File for Upload
   $content = [System.IO.File]::ReadAllBytes($LocalFile)

   $FTPRequest.ContentLength = $content.Length
   $rs = $FTPRequest.GetRequestStream()
   $rs.Write($content, 0, $content.Length)

   Write-Host "Uploading" + $file.FullName

   # be sure to clean up after ourselves
   $rs.Close()
   $rs.Dispose()
  }

function Publish-Directory {
  param (
    [string]$URIBase,
    [string]$ServerBase,
    [string]$DirectoryName
  )
    # Create FTP Rquest Object
    $FTPRequest = [System.Net.FtpWebRequest]::Create( [system.URI]($URIBase + '/' + $ServerBase + '/' + $DirectoryName))
    $FTPRequest = [System.Net.FtpWebRequest]$FTPRequest
    $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
    $FTPRequest.Credentials = new-object System.Net.NetworkCredential($ENV:USERNAME, $ENV:PASSWORD)
    $FTPRequest.UseBinary = $true
    $FTPRequest.UsePassive = $true
    $FTPRequest.EnableSsl = $true;

    $ErrorActionPreference = "Continue"

    $FTPRequest.GetResponse() 

    $ErrorActionPreference = "Stop"
  }

foreach ($folder in 'apis','programs'){

  $files = Get-ChildItem ($PSScriptRoot + '/' + $folder) -File
  Publish-Directory $ENV:SERVER $ENV:SERVER_BASE $folder 

  foreach ($file in $files)
  {
    Publish-File $ENV:SERVER $ENV:SERVER_BASE ($folder + '/' + $file.Name) $file.FullName


  } 
}

set-content env:PASSWORD '-1'

Write-Output 'Upload completed'
