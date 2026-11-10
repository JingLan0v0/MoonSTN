$ErrorActionPreference='Stop'
$root=Split-Path $PSScriptRoot -Parent
$wrapper=Join-Path $PSScriptRoot 'moon.ps1'
Push-Location ([IO.Path]::GetTempPath())
try {
  $before=(Get-Location).Path
  $output='{"timepoints":["zero"],"constraints":[]}' | & $wrapper run cmd/main --target js -- -
  if ($LASTEXITCODE -ne 0 -or ($output | ConvertFrom-Json).status -ne 'feasible') { throw 'Pipeline failed' }
  if ((Get-Location).Path -ne $before) { throw 'Directory restoration failed' }
  foreach ($scenario in @('deployment','delivery','conflict')) {
    $output=& $wrapper run cmd/main --target js -- (Join-Path $root "examples/$scenario.json")
    if ($LASTEXITCODE -ne 0) { throw "Scenario failed: $scenario" }
    $expected=if ($scenario -eq 'conflict') {'inconsistent'} else {'feasible'}
    if (($output | ConvertFrom-Json).status -ne $expected) { throw 'Unexpected scenario result' }
  }
} finally { Pop-Location }
Write-Host 'PASS PowerShell pipeline, three scenarios and directory restoration'
