[CmdletBinding(PositionalBinding=$false)]
param([Parameter(ValueFromPipeline=$true)][string]$InputLine,[Parameter(ValueFromRemainingArguments=$true)][string[]]$MoonArgs)
begin { $ErrorActionPreference='Stop'; $lines=[Collections.Generic.List[string]]::new() }
process { if ($null -ne $InputLine) { $lines.Add($InputLine) } }
end {
  $root=Split-Path $PSScriptRoot -Parent
  $candidates=@($env:MOON_HOME,(Join-Path (Split-Path $root -Parent) '.tools/moonstn-toolchain'),(Join-Path (Split-Path $root -Parent) 'MoonBit黑客松/.tools/moonstn-toolchain'))
  $installation=$candidates | Where-Object { $_ -and (Test-Path -LiteralPath (Join-Path $_ 'bin/moon.exe')) } | Select-Object -First 1
  if ($installation) { $env:MOON_HOME=$installation; $moonExecutable=Join-Path $installation 'bin/moon.exe' } else { $moonExecutable=(Get-Command moon -ErrorAction Stop).Source }
  Push-Location $root
  try { if ($lines.Count) { $lines | & $moonExecutable @MoonArgs } else { & $moonExecutable @MoonArgs }; $code=$LASTEXITCODE } finally { Pop-Location }
  exit $code
}
