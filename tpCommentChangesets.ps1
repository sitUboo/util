# buildId  =>  %teamcity.build.id%
# buildConfigId  => %system.teamcity.buildType.id%
# buildNum  => %env.TEAMCITY_BUILDCONF_NAME%.%build.number%
param
(
  [parameter(Mandatory = $true)]
  [string]
  $buildId,
  [parameter(Mandatory = $true)]
  [string]
  $buildConfigId,
  [parameter(Mandatory = $true)]
  [string]
  $buildNum
)

function updateTargetProcess ($tpid, $build) {
  try {
    #$command = '{Description:"<div>BUILD:'+ $build +'</div>", General:{Id:' + $tpid +'}}'
    $command = '{Description:"Integrated in build:<a href="http://vmteambuildserver/viewLog.html?buildId='+ $buildId +'&tab=buildResultsDiv&buildTypeId=' + $buildConfigId +'">' + $build + '</a>", General:{Id:' + $tpid +'}}'
    Write-Host $command
    $bytes = [System.Text.Encoding]::ASCII.GetBytes($command)
    $url = "http://vmtargetprocess/targetprocess2/api/v1/Comments"
    $req = [System.Net.WebRequest]::Create($url)
    $req.credentials = new-object system.net.networkcredential("sdeal", "Jannina1111")
    $req.Method = "POST"
    $req.ContentLength = $bytes.Length
    $req.ContentType = "application/json"
    $stream = $req.GetRequestStream()
    $stream.Write($bytes,0,$bytes.Length)
    $stream.close()
    $reader = New-Object System.IO.Streamreader -ArgumentList $req.GetResponse().GetResponseStream()
    $output = $reader.ReadToEnd()
    $reader.Close()
    Write-Host $output
  }catch{
    Write-Host "Unable to update TargetProcess. Error: $error"
  }
}

$baseurl = "http://vmteambuildserver";
$url = "$baseurl/httpAuth/app/rest/changes?buildType=id:$buildConfigId&build=id:$buildId";
# WORKS $url = "$baseurl/httpAuth/app/rest/changes?buildType=id:bt32&build=id:3286";
$webclient = new-object system.net.webclient
$webclient.credentials = new-object system.net.networkcredential("sdeal", "Jannina1111")
$result = [xml] $webclient.DownloadString($url)
foreach ($change in ($result.changes.change)){
  if($change){
    $cs = [xml] $webclient.DownloadString($baseurl + $change.GetAttribute("href"));
    foreach ($comment in ($cs.change.comment)){
      if($comment -match ("#([0-9]*)")){
        updateTargetProcess $matches[1] $buildNum
      }elseif($comment -match ("TA([0-9]*)")){
        updateTargetProcess $matches[1] $buildNum
      }
    }
  }
}

