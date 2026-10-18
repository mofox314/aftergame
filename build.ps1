$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$gamesRoot = Join-Path $root 'games'
$webRoot = Join-Path $root 'web'
$siteRoot = Join-Path $root 'site'
$jsonPath = Join-Path $root 'games.json'
$utf8 = [System.Text.UTF8Encoding]::new($false)

try {
    $rootFull = [System.IO.Path]::GetFullPath($root).TrimEnd('\')
    $siteFull = [System.IO.Path]::GetFullPath($siteRoot)
    if (-not $siteFull.StartsWith($rootFull + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Unsafe site output path.'
    }
    if (-not (Test-Path -LiteralPath $gamesRoot -PathType Container)) { throw 'The games folder is missing.' }
    if (-not (Test-Path -LiteralPath $webRoot -PathType Container)) { throw 'The web folder is missing.' }
    if (Test-Path -LiteralPath $siteRoot) { Remove-Item -LiteralPath $siteRoot -Recurse -Force }
    New-Item -ItemType Directory -Force $siteRoot | Out-Null
    $imageRoot = Join-Path $siteRoot 'images'
    New-Item -ItemType Directory -Force $imageRoot | Out-Null
    foreach ($file in Get-ChildItem -LiteralPath $webRoot -File) {
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $siteRoot $file.Name) -Force
    }

    $seenTitles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $records = [System.Collections.Generic.List[object]]::new()
    foreach ($folder in Get-ChildItem -LiteralPath $gamesRoot -Directory) {
        if ($folder.Name.StartsWith('_')) { continue }
        $titleFile = Join-Path $folder.FullName 'title.txt'
        $scoreFile = Join-Path $folder.FullName 'score.txt'
        $descriptionFile = Join-Path $folder.FullName 'description.txt'
        foreach ($required in @($titleFile, $scoreFile, $descriptionFile)) {
            if (-not (Test-Path -LiteralPath $required -PathType Leaf)) { throw "Missing $required" }
        }
        $title = [System.IO.File]::ReadAllText($titleFile, [System.Text.Encoding]::UTF8).Trim()
        $scoreText = [System.IO.File]::ReadAllText($scoreFile, [System.Text.Encoding]::UTF8).Trim()
        $description = [System.IO.File]::ReadAllText($descriptionFile, [System.Text.Encoding]::UTF8).Trim()
        if (-not $title -or $title.Length -gt 100) { throw "Invalid title in $($folder.Name)." }
        if (-not $seenTitles.Add($title)) { throw "Duplicate title: $title" }
        if ($scoreText -notmatch '^(10|[1-9])$') { throw "Score must be 1-10 in $($folder.Name)." }
        if ($description.Length -gt 30000) { throw "Description is too long in $($folder.Name)." }
        $cover = $null
        foreach ($name in @('cover.jpg', 'cover.jpeg', 'cover.png', 'cover.webp', 'cover.svg')) {
            $candidate = Join-Path $folder.FullName $name
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $cover = Get-Item -LiteralPath $candidate; break }
        }
        if (-not $cover) { throw "Missing cover image in $($folder.Name)." }
        if ($cover.Length -gt 10MB) { throw "Cover image exceeds 10 MB in $($folder.Name)." }
        $hash = [System.Security.Cryptography.SHA256]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($folder.Name))
        $id = [System.BitConverter]::ToString($hash).Replace('-', '').Substring(0, 12).ToLowerInvariant()
        $imageName = $id + $cover.Extension.ToLowerInvariant()
        Copy-Item -LiteralPath $cover.FullName -Destination (Join-Path $imageRoot $imageName) -Force
        $records.Add([pscustomobject][ordered]@{
            id = $id
            title = $title
            score = [int]$scoreText
            description = $description
            image = 'images/' + $imageName
        })
    }

    $sorted = @($records.ToArray() | Sort-Object -Property @{ Expression = { $_.title.ToLowerInvariant() } })
    $json = if ($sorted.Count -eq 0) { '[]' } else { ConvertTo-Json -InputObject $sorted -Depth 5 }
    [System.IO.File]::WriteAllText($jsonPath, $json + [Environment]::NewLine, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $siteRoot 'games.json'), $json + [Environment]::NewLine, $utf8)
    [System.IO.File]::WriteAllText((Join-Path $siteRoot 'data.js'), 'window.AFTERGAME_GAMES = ' + $json + ';' + [Environment]::NewLine, $utf8)
    Write-Host "Built games.json and site/ with $($sorted.Count) games."
    exit 0
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
