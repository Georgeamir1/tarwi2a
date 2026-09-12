[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ArtifactPath,
    [Parameter(Mandatory = $true)][string]$AndroidSdkRoot
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$artifact = (Resolve-Path -LiteralPath $ArtifactPath).Path
$archive = [IO.Compression.ZipFile]::OpenRead($artifact)
$checked = 0
$problems = [Collections.Generic.List[string]]::new()
try {
    foreach ($entry in $archive.Entries) {
        if ($entry.FullName -notmatch '(^|/)lib/(arm64-v8a|x86_64)/.+\.so$') { continue }
        $memory = [IO.MemoryStream]::new()
        $stream = $entry.Open()
        try { $stream.CopyTo($memory); $bytes = $memory.ToArray() }
        finally { $stream.Dispose(); $memory.Dispose() }
        if ($bytes.Length -lt 64 -or $bytes[0] -ne 127 -or $bytes[1] -ne 69 -or $bytes[2] -ne 76 -or $bytes[3] -ne 70 -or $bytes[4] -ne 2 -or $bytes[5] -ne 1) {
            throw "Unsupported ELF file: $($entry.FullName)"
        }
        $offset = [BitConverter]::ToUInt64($bytes, 32)
        $size = [BitConverter]::ToUInt16($bytes, 54)
        $count = [BitConverter]::ToUInt16($bytes, 56)
        $loads = 0
        $writableSegments = [Collections.Generic.List[object]]::new()
        $relroEnds = [Collections.Generic.List[UInt64]]::new()
        for ($i = 0; $i -lt $count; $i++) {
            $at = [int]($offset + $i * $size)
            if ($size -lt 56 -or $at + 56 -gt $bytes.Length) { throw 'Malformed ELF program headers.' }
            $type = [BitConverter]::ToUInt32($bytes, $at)
            $virtual = [BitConverter]::ToUInt64($bytes, $at + 16)
            if ($type -eq 1) {
                $loads++
                $flags = [BitConverter]::ToUInt32($bytes, $at + 4)
                $memorySize = [BitConverter]::ToUInt64($bytes, $at + 40)
                if (($flags -band 2) -ne 0) {
                    $writableSegments.Add(@{ Start = $virtual; End = $virtual + $memorySize })
                }
                $alignment = [BitConverter]::ToUInt64($bytes, $at + 48)
                $fileOffset = [BitConverter]::ToUInt64($bytes, $at + 8)
                if ($alignment -lt 16384 -or ($virtual % 16384) -ne ($fileOffset % 16384)) {
                    $problems.Add("$($entry.FullName): PT_LOAD alignment below 16 KB")
                }
            }
            if ($type -eq 1685382482) {
                $memorySize = [BitConverter]::ToUInt64($bytes, $at + 40)
                $relroEnds.Add($virtual + $memorySize)
            }
        }
        foreach ($end in $relroEnds) {
            if ($end % 16384 -eq 0) { continue }
            $protectedEnd = $end + 16384 - ($end % 16384)
            # Older linkers pad RELRO to 4 KB while leaving an unmapped gap up
            # to the next LOAD segment. That gap is harmless. Reject when 16 KB
            # protection would actually overlap bytes required to be writable.
            foreach ($segment in $writableSegments) {
                if ($segment.End -gt $end -and $segment.Start -lt $protectedEnd) {
                    $problems.Add("$($entry.FullName): GNU_RELRO protection overlaps writable data at 16 KB")
                }
            }
        }
        if ($loads -eq 0) { throw "No load segments found in $($entry.FullName)" }
        $checked++
        Write-Output "Inspected $($entry.FullName)"
    }
} finally { $archive.Dispose() }
if ($checked -eq 0) { throw 'No 64-bit native libraries found; cannot verify this artifact.' }
if ($problems.Count -gt 0) { throw ($problems -join [Environment]::NewLine) }
Write-Output "ELF alignment passed for $checked libraries."
if ([IO.Path]::GetExtension($artifact) -eq '.apk') {
    $buildTools = Get-ChildItem -LiteralPath (Join-Path $AndroidSdkRoot 'build-tools') -Directory |
        Where-Object { $_.Name -match '^\d+\.\d+\.\d+$' -and [version]$_.Name -ge [version]'35.0.0' } |
        Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1
    if (-not $buildTools) { throw 'Android Build Tools 35+ are required for zipalign verification.' }
    $zipalign = Join-Path $buildTools.FullName 'zipalign.exe'
    if (-not (Test-Path -LiteralPath $zipalign)) { $zipalign = Join-Path $buildTools.FullName 'zipalign' }
    & $zipalign -c -P 16 4 $artifact
    if ($LASTEXITCODE -ne 0) { throw 'APK ZIP alignment failed.' }
    Write-Output 'APK ZIP alignment passed. Runtime testing on a 16 KB device remains required.'
} else {
    Write-Output 'AAB ELF check only: verify BundleConfig with bundletool and ZIP alignment of generated APKs separately.'
}
