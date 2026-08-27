[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$validator = Join-Path $PSScriptRoot 'validate-script.ps1'
$validFixture = Join-Path $projectRoot 'tests/fixtures/validator-valid.md'
$invalidFixture = Join-Path $projectRoot 'tests/fixtures/validator-invalid.md'
$v3ValidFixture = Join-Path $projectRoot 'tests/fixtures/validator-v3-valid.md'
$v3InvalidFixture = Join-Path $projectRoot 'tests/fixtures/validator-v3-invalid.md'
$powershellExe = (Get-Process -Id $PID).Path

& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $validFixture
if ($LASTEXITCODE -ne 0) {
    throw 'Expected validator-valid.md to pass.'
}

& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $invalidFixture
if ($LASTEXITCODE -eq 0) {
    throw 'Expected validator-invalid.md to fail.'
}

& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $v3ValidFixture -Strict
if ($LASTEXITCODE -ne 0) {
    throw 'Expected validator-v3-valid.md to pass.'
}

& $powershellExe -NoProfile -ExecutionPolicy Bypass -File $validator -Path $v3InvalidFixture -Strict
if ($LASTEXITCODE -eq 0) {
    throw 'Expected validator-v3-invalid.md to fail.'
}

Write-Host 'Validator tests passed.'
