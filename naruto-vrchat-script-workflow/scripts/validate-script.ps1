[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$Path,

    [switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$durationLabel = [string]([char]0x65F6) + [char]0x957F
$characterLabel = [string]([char]0x51FA) + [char]0x573A + [char]0x89D2 + [char]0x8272
$dialogueHeading = [string]([char]0x53E3) + [char]0x64AD + [char]0x53F0 + [char]0x8BCD + [char]0x7248
$issueHeading = [string]([char]0x4E3B) + [char]0x8981 + [char]0x95EE + [char]0x9898
$conclusionHeading = [string]([char]0x7ED3) + [char]0x8BBA
$passLabel = [string]([char]0x901A) + [char]0x8FC7
$workflowLabel = [string]([char]0x5DE5) + [char]0x4F5C + [char]0x6D41 + [char]0x7248 + [char]0x672C
$powerShiftLabel = [string]([char]0x7B2C) + [char]0x4E00 + [char]0x6B21 + [char]0x4E3B + [char]0x52A8 + [char]0x6743 + [char]0x8F6C + [char]0x79FB
$secondInfoLabel = [string]([char]0x7B2C) + [char]0x4E8C + [char]0x4E2A + [char]0x65B0 + [char]0x4FE1 + [char]0x606F
$peakLineLabel = [string]([char]0x6700) + [char]0x5F3A + [char]0x5305 + [char]0x88B1
$postPeakLabel = $peakLineLabel + [char]0x540E + [char]0x53E3 + [char]0x64AD + [char]0x53E5 + [char]0x6570
$middleDeleteLabel = [string]([char]0x4E2D) + [char]0x6BB5 + [char]0x5220 + [char]0x9664 + [char]0x6D4B + [char]0x8BD5
$expansionLabel = [string]([char]0x6269) + [char]0x5199 + [char]0x56DE + [char]0x5F52
$passedValue = [string]([char]0x901A) + [char]0x8FC7
$fullWidthColon = [char]0xFF1A
$chineseComma = [char]0xFF0C
$ideographicComma = [char]0x3001

$results = [System.Collections.Generic.List[object]]::new()
$dialogueIndex = @{}

function Add-Finding {
    param(
        [System.Collections.Generic.List[object]]$Findings,
        [ValidateSet('ERROR', 'WARN', 'INFO')]
        [string]$Level,
        [string]$Code,
        [string]$Message
    )

    $Findings.Add([PSCustomObject]@{
        Level   = $Level
        Code    = $Code
        Message = $Message
    })
}

function Get-ScriptFiles {
    param([string[]]$InputPaths)

    $files = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($inputPath in $InputPaths) {
        if (-not (Test-Path -LiteralPath $inputPath)) {
            throw "Path not found: $inputPath"
        }

        $item = Get-Item -LiteralPath $inputPath
        if ($item.PSIsContainer) {
            Get-ChildItem -LiteralPath $item.FullName -Filter '*.md' -File |
                ForEach-Object { $files.Add($_) }
        }
        else {
            $files.Add($item)
        }
    }

    return $files | Sort-Object FullName -Unique
}

foreach ($file in (Get-ScriptFiles -InputPaths $Path)) {
    $content = Get-Content -Raw -Encoding UTF8 -LiteralPath $file.FullName
    $findings = [System.Collections.Generic.List[object]]::new()

    $durationPattern = '(?m)^\-\s*' + [regex]::Escape($durationLabel) + '[^\d\r\n]*(\d+)\s*[^\r\n]*$'
    $durationMatch = [regex]::Match($content, $durationPattern)
    $declaredDuration = $null
    if ($durationMatch.Success) {
        $declaredDuration = [int]$durationMatch.Groups[1].Value
        if ($declaredDuration -lt 30 -or $declaredDuration -gt 90) {
            Add-Finding $findings 'ERROR' 'DURATION_RANGE' "Declared duration ${declaredDuration}s is outside 30-90s."
        }
    }
    else {
        Add-Finding $findings 'ERROR' 'DURATION_MISSING' 'Missing declared duration field.'
    }

    $timelineMatches = [regex]::Matches($content, '(?m)^\|\s*(\d+)\s*-\s*(\d+)s\s*\|')
    $timelineEnd = $null
    $previousEnd = $null
    foreach ($match in $timelineMatches) {
        $start = [int]$match.Groups[1].Value
        $end = [int]$match.Groups[2].Value
        if ($end -le $start) {
            Add-Finding $findings 'ERROR' 'TIMELINE_ORDER' "Invalid timeline range: ${start}-${end}s."
        }
        if ($null -ne $previousEnd -and $start -ne $previousEnd) {
            Add-Finding $findings 'WARN' 'TIMELINE_GAP' "Timeline is discontinuous between ${previousEnd}s and ${start}s."
        }
        $previousEnd = $end
        if ($null -eq $timelineEnd -or $end -gt $timelineEnd) {
            $timelineEnd = $end
        }
    }

    if ($timelineMatches.Count -eq 0) {
        Add-Finding $findings 'ERROR' 'TIMELINE_MISSING' 'No VRChat shot timeline found.'
    }
    else {
        if ($timelineEnd -gt 90) {
            Add-Finding $findings 'ERROR' 'TIMELINE_TOO_LONG' "Timeline ends at ${timelineEnd}s, above the 90s limit."
        }
        if ($null -ne $declaredDuration -and [math]::Abs($timelineEnd - $declaredDuration) -gt 5) {
            Add-Finding $findings 'ERROR' 'DURATION_MISMATCH' "Declared ${declaredDuration}s but timeline ends at ${timelineEnd}s."
        }

        if ($timelineMatches.Count -gt 24) {
            Add-Finding $findings 'ERROR' 'SHOT_COUNT' "$($timelineMatches.Count) shots exceeds the hard limit of 24."
        }
        elseif ($timelineMatches.Count -gt 18) {
            $level = if ($Strict) { 'ERROR' } else { 'WARN' }
            Add-Finding $findings $level 'SHOT_COUNT' "$($timelineMatches.Count) shots; compress to 18 or fewer."
        }
    }

    $characterPattern = '(?m)^\-\s*' + [regex]::Escape($characterLabel) + '\s*' + [regex]::Escape($fullWidthColon) + '(.+)$'
    $characterMatch = [regex]::Match($content, $characterPattern)
    if ($characterMatch.Success) {
        $delimiterPattern = '[|,/' + [regex]::Escape($chineseComma) + [regex]::Escape($ideographicComma) + ']'
        $characters = $characterMatch.Groups[1].Value -split $delimiterPattern
        $characterCount = @($characters | Where-Object { $_.Trim() }).Count
        if ($characterCount -gt 4) {
            Add-Finding $findings 'ERROR' 'CHARACTER_COUNT' "$characterCount characters exceeds the limit of 4."
        }
    }
    else {
        Add-Finding $findings 'WARN' 'CHARACTERS_MISSING' 'Missing character list.'
    }

    $dialoguePattern = '(?s)##\s*' + [regex]::Escape($dialogueHeading) + '.*?```text\s*(.*?)```'
    $dialogueBlock = [regex]::Match($content, $dialoguePattern)
    $dialogueLines = @()
    if (-not $dialogueBlock.Success) {
        Add-Finding $findings 'ERROR' 'DIALOGUE_MISSING' 'No spoken-dialogue text block found.'
    }
    else {
        $dialogueLines = @($dialogueBlock.Groups[1].Value -split '\r?\n' |
            Where-Object { $_.IndexOf($fullWidthColon) -gt 0 })
        if ($dialogueLines.Count -lt 8) {
            Add-Finding $findings 'WARN' 'DIALOGUE_TOO_SHORT' "Only $($dialogueLines.Count) dialogue lines found."
        }

        foreach ($line in $dialogueLines) {
            $colonIndex = $line.IndexOf($fullWidthColon)
            $spokenText = ($line.Substring($colonIndex + 1) -replace '\s', '')
            if ($spokenText.Length -gt 30) {
                Add-Finding $findings 'WARN' 'LONG_LINE' "Dialogue line has $($spokenText.Length) characters: $line"
            }

            $normalized = $spokenText -replace '[^\p{L}\p{N}]', ''
            if ($normalized.Length -ge 8) {
                if (-not $dialogueIndex.ContainsKey($normalized)) {
                    $dialogueIndex[$normalized] = [System.Collections.Generic.HashSet[string]]::new()
                }
                [void]$dialogueIndex[$normalized].Add($file.Name)
            }
        }
    }

    $workflowPattern = '(?m)^\-\s*' + [regex]::Escape($workflowLabel) + '\s*' + [regex]::Escape($fullWidthColon) + '\s*V3\s*$'
    $isV3 = $content -match $workflowPattern
    if ($isV3 -and $dialogueLines.Count -gt 0) {
        $contractValues = @{}
        foreach ($contract in @(
            @{ Key = 'power_shift'; Label = $powerShiftLabel },
            @{ Key = 'second_info'; Label = $secondInfoLabel },
            @{ Key = 'peak_line'; Label = $peakLineLabel },
            @{ Key = 'post_peak'; Label = $postPeakLabel }
        )) {
            $pattern = '(?m)^\-\s*' + [regex]::Escape($contract.Label) + '\s*' + [regex]::Escape($fullWidthColon) + '[^\d\r\n]*(\d+)'
            $match = [regex]::Match($content, $pattern)
            if (-not $match.Success) {
                Add-Finding $findings 'ERROR' 'COMEDY_CONTRACT_MISSING' "Missing V3 comedy contract field: $($contract.Key)."
            }
            else {
                $contractValues[$contract.Key] = [int]$match.Groups[1].Value
            }
        }

        if ($contractValues.ContainsKey('power_shift')) {
            $line = $contractValues['power_shift']
            if ($line -lt 1 -or $line -gt $dialogueLines.Count) {
                Add-Finding $findings 'ERROR' 'POWER_SHIFT_RANGE' "Power-shift line $line is outside the $($dialogueLines.Count)-line dialogue."
            }
            elseif ($line -gt 5) {
                Add-Finding $findings 'ERROR' 'POWER_SHIFT_LATE' "First power shift is at line $line; V3 requires line 5 or earlier."
            }
        }

        if ($contractValues.ContainsKey('second_info')) {
            $line = $contractValues['second_info']
            if ($line -lt 2 -or $line -gt $dialogueLines.Count) {
                Add-Finding $findings 'ERROR' 'SECOND_INFO_RANGE' "Second-information line $line is outside the usable dialogue range."
            }
        }

        if ($contractValues.ContainsKey('peak_line')) {
            $peakLine = $contractValues['peak_line']
            $minimumPeakLine = [int][math]::Ceiling($dialogueLines.Count * 0.75)
            if ($peakLine -lt 1 -or $peakLine -gt $dialogueLines.Count) {
                Add-Finding $findings 'ERROR' 'PEAK_LINE_RANGE' "Peak line $peakLine is outside the $($dialogueLines.Count)-line dialogue."
            }
            elseif ($peakLine -lt $minimumPeakLine) {
                Add-Finding $findings 'ERROR' 'PEAK_TOO_EARLY' "Peak line $peakLine is too early; expected line $minimumPeakLine or later."
            }

            if ($contractValues.ContainsKey('post_peak') -and $peakLine -ge 1 -and $peakLine -le $dialogueLines.Count) {
                $declaredPostPeak = $contractValues['post_peak']
                $actualPostPeak = $dialogueLines.Count - $peakLine
                if ($declaredPostPeak -ne $actualPostPeak) {
                    Add-Finding $findings 'ERROR' 'POST_PEAK_MISMATCH' "Declared $declaredPostPeak post-peak lines but dialogue contains $actualPostPeak."
                }
                if ($actualPostPeak -gt 1) {
                    Add-Finding $findings 'ERROR' 'POST_PEAK_EXCESS' "$actualPostPeak spoken lines follow the peak; V3 permits at most 1."
                }
            }
        }

        $deletePattern = '(?m)^\-\s*' + [regex]::Escape($middleDeleteLabel) + '\s*' + [regex]::Escape($fullWidthColon) + '\s*' + [regex]::Escape($passedValue) + '\s*$'
        if ($content -notmatch $deletePattern) {
            Add-Finding $findings 'ERROR' 'MIDDLE_DELETE_TEST' 'V3 middle deletion test is missing or not passed.'
        }

        $expansionPattern = '(?m)^\-\s*' + [regex]::Escape($expansionLabel) + '\s*' + [regex]::Escape($fullWidthColon) + '\s*(expanded_clean|cold_open_wins)\s*$'
        if ($content -notmatch $expansionPattern) {
            Add-Finding $findings 'ERROR' 'EXPANSION_REGRESSION' 'V3 expansion result must be expanded_clean or cold_open_wins.'
        }
    }

    $issuePattern = '(?s)##\s*' + [regex]::Escape($issueHeading) + '\s*(.*?)(?=\r?\n##|\z)'
    $issueSection = [regex]::Match($content, $issuePattern)
    if (-not $issueSection.Success -or $issueSection.Groups[1].Value -notmatch '(?m)^\s*\d+\.\s*\S.{5,}') {
        Add-Finding $findings 'ERROR' 'ISSUES_NOT_CONCRETE' 'Quality review needs at least one concrete, actionable issue.'
    }

    $scores = @([regex]::Matches($content, '\|\s*(\d+)\s*/\s*10\s*\|') |
        ForEach-Object { [int]$_.Groups[1].Value })
    if ($scores.Count -ge 5 -and ($scores | Measure-Object -Minimum).Minimum -ge 8) {
        Add-Finding $findings 'WARN' 'SCORE_INFLATION' 'All review scores are 8 or above; recalibrate the review.'
    }

    $passPattern = '(?ms)^##\s*' + [regex]::Escape($conclusionHeading) + '\s*\r?\n-\s*' + [regex]::Escape($passLabel) + '\s*$'
    $hasPassConclusion = $content -match $passPattern
    $hardErrorCount = @($findings | Where-Object Level -eq 'ERROR').Count
    if ($hasPassConclusion -and $hardErrorCount -gt 0) {
        Add-Finding $findings 'ERROR' 'FALSE_PASS' 'Review says PASS while hard validation errors exist.'
    }

    $results.Add([PSCustomObject]@{
        File             = $file.FullName
        DeclaredDuration = $declaredDuration
        TimelineEnd      = $timelineEnd
        ShotCount        = $timelineMatches.Count
        Findings         = $findings
    })
}

foreach ($entry in $dialogueIndex.GetEnumerator()) {
    if ($entry.Value.Count -gt 1) {
        $files = ($entry.Value | Sort-Object) -join ', '
        Write-Host "[WARN] REPEATED_LINE: '$($entry.Key)' appears in $files"
    }
}

$totalErrors = 0
$totalWarnings = 0
foreach ($result in $results) {
    Write-Host "`n$($result.File)"
    Write-Host "  Declared: $($result.DeclaredDuration)s; timeline: $($result.TimelineEnd)s; shots: $($result.ShotCount)"
    if ($result.Findings.Count -eq 0) {
        Write-Host '  [OK] No hard validation findings.'
        continue
    }

    foreach ($finding in $result.Findings) {
        Write-Host "  [$($finding.Level)] $($finding.Code): $($finding.Message)"
        if ($finding.Level -eq 'ERROR') { $totalErrors++ }
        if ($finding.Level -eq 'WARN') { $totalWarnings++ }
    }
}

Write-Host "`nSummary: $($results.Count) file(s), $totalErrors error(s), $totalWarnings warning(s)."
if ($totalErrors -gt 0) {
    exit 1
}

exit 0
