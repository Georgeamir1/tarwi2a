[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ConfigPath,
    [Parameter(Mandatory = $true)][ValidateRange(1, 2100000000)][int]$BuildNumber
)
$ErrorActionPreference = 'Stop'
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$resolvedConfig = (Resolve-Path -LiteralPath $ConfigPath).Path
$config = Get-Content -LiteralPath $resolvedConfig -Raw | ConvertFrom-Json
$required = @('SUPABASE_URL', 'SUPABASE_ANON_KEY', 'PRIVACY_POLICY_URL', 'TERMS_OF_SERVICE_URL', 'SUPPORT_URL', 'ACCOUNT_DELETION_URL')
foreach ($name in $required) {
    $value = [string]$config.$name
    if ([string]::IsNullOrWhiteSpace($value) -or $value -match 'REPLACE_|example\.|\.invalid|YOUR_') {
        throw "Release configuration is missing a real value for $name."
    }
    if ($name.EndsWith('_URL')) {
        $uri = $null
        if (-not [Uri]::TryCreate($value, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -ne 'https') {
            throw "$name must be an absolute HTTPS URL."
        }
    }
}
$clientKey = [string]$config.SUPABASE_ANON_KEY
if ($clientKey.StartsWith('sb_secret_')) { throw 'Use a publishable/anon client key, never a server secret.' }
if ($clientKey.StartsWith('eyJ')) {
    try {
        $part = $clientKey.Split('.')[1].Replace('-', '+').Replace('_', '/')
        $part = $part.PadRight($part.Length + ((4 - $part.Length % 4) % 4), '=')
        $claims = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($part)) | ConvertFrom-Json
        if ($claims.role -ne 'anon') { throw 'Wrong role' }
    } catch { throw 'The client JWT must be a valid anon key; its value has not been logged.' }
} elseif (-not $clientKey.StartsWith('sb_publishable_')) {
    throw 'Expected a Supabase publishable key or legacy anon JWT.'
}
if (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'android/key.properties'))) {
    throw 'Owner step: configure android/key.properties using android/key.properties.example.'
}

function Invoke-Checked([string]$Command, [string[]]$Arguments) {
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Command failed (exit $LASTEXITCODE). Release stopped." }
}

Push-Location $repoRoot
try {
    Invoke-Checked 'flutter' @('pub', 'get', '--enforce-lockfile')
    Invoke-Checked 'dart' @('format', '--output=none', '--set-exit-if-changed', 'lib', 'test', 'integration_test')
    Invoke-Checked 'flutter' @('analyze', '--no-pub', '--fatal-warnings', '--fatal-infos')
    Invoke-Checked 'flutter' @('test', '--no-pub', '--coverage')
    Invoke-Checked 'npm' @('ci', '--prefix', 'tools/release', '--ignore-scripts', '--no-audit', '--no-fund')
    Invoke-Checked 'npm' @('test', '--prefix', 'tools/release')
    Invoke-Checked 'flutter' @('build', 'appbundle', '--release', '--no-pub', "--build-number=$BuildNumber", "--dart-define-from-file=$resolvedConfig")
    $bundle = Join-Path $repoRoot 'build/app/outputs/bundle/release/app-release.aab'
    if (-not (Test-Path -LiteralPath $bundle)) { throw 'Build returned without producing the expected AAB.' }
    Get-FileHash -LiteralPath $bundle -Algorithm SHA256
    Write-Output "Bundle: $bundle"
    Write-Output 'Next: verify upload certificate, bundle metadata/16 KB compatibility, and install through Play Internal testing.'
} finally { Pop-Location }
