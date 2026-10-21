### Variables

# Where to save the timelapses
$basedir = Join-Path $env:USERPROFILE "timelapses"

# Record from start hour up to (not including) the end hour, 24h clock.
# Works across midnight: 22 and 5 means 22:00 through 04:59.
# Set both to $null for a 24 hour timelapse.
$start_record = 22
$stop_record  = 5

# Take a frame every X minutes
$interval = 1

# Path to ffmpeg (just "ffmpeg" if it's on your PATH)
$ffmpeg = ".\ffmpeg"

### don't edit below this line

if ($args.Count -ge 1) {
    $timelapsename = $args[0]
} else {
    $timelapsename = Read-Host "Enter timelapse name"
}

$fulldir  = Join-Path $basedir $timelapsename
$imagedir = Join-Path $fulldir "images"
$null = New-Item -ItemType Directory -Force -Path $imagedir
$mydate = Get-Date -Format "MM-dd-yyyy"

Write-Host "[+] Generating file list for every $interval minutes"

# Minute names to keep: 00, 10, 20, ...
$minutes = @()
for ($m = 0; $m -le 59; $m += $interval) {
    $minutes += $m.ToString("00")
}

$usehours = (($null -ne $start_record) -and ($null -ne $stop_record))

# Expects layout: <current dir>\<date>\<hour>\<minute>.mp4
$files = @()
foreach ($f in Get-ChildItem -Path . -Recurse -Filter "*.mp4" -File) {
    if ($minutes -notcontains $f.BaseName) { continue }
    if ($f.FullName -like "$fulldir*") { continue }

    if ($usehours) {
        $hour = [int]$f.Directory.Name
        if ($start_record -gt $stop_record) {
            # window crosses midnight, e.g. 22 -> 5
            $keep = (($hour -ge $start_record) -or ($hour -lt $stop_record))
        } else {
            # same-day window, e.g. 9 -> 17
            $keep = (($hour -ge $start_record) -and ($hour -lt $stop_record))
        }
        if (-not $keep) { continue }
    }

    $files += $f
}

Write-Host "Found $($files.Count) clips to use"
Write-Host "[###] Extracting Images from $(Get-Location)"
foreach ($f in $files) {
    $date = $f.Directory.Parent.Name
    $hour = $f.Directory.Name
    $min  = $f.BaseName
    $combined = "$date-$hour-$min"
    $out = Join-Path $imagedir "$combined.jpeg"

    if (Test-Path $out) {
        Write-Host "$combined.jpeg already exists. Skipping"
    } else {
        Write-Host " [+] $combined --> images\$combined.jpeg"
        & $ffmpeg -n -i $f.FullName -frames:v 1 $out *> $null
    }
}

Write-Host "[###] Creating timelapse"

# Windows ffmpeg builds don't support glob patterns, so build a concat list instead
$images = @(Get-ChildItem -Path $imagedir -Filter "*.jpeg" -File | Sort-Object Name)
if ($images.Count -eq 0) {
    Write-Host "No images found. Nothing to do."
    exit 1
}

$lines = @()
foreach ($img in $images) {
    $p = $img.FullName.Replace('\', '/').Replace("'", "'\''")
    $lines += "file '$p'"
    $lines += "duration 0.033333"
}
# concat demuxer ignores the last duration, so repeat the final frame
$lastp = $images[-1].FullName.Replace('\', '/').Replace("'", "'\''")
$lines += "file '$lastp'"

$listfile = Join-Path $fulldir "images.txt"
Set-Content -Path $listfile -Value $lines -Encoding ascii

$outfile = Join-Path $fulldir "$timelapsename-$mydate.mp4"
& $ffmpeg -y -f concat -safe 0 -i $listfile -r 30 -c:v libx264 -pix_fmt yuv420p $outfile

Write-Host "Done. $outfile"
