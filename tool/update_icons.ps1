Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Code\GitHub\EasyPlayer\artwork\Neon Panda Play Icon.png"
if (!(Test-Path $srcPath)) {
    $srcPath = "C:\Code\GitHub\EasyPlayer\artwork\logo_transparent.png"
}
$src = [System.Drawing.Bitmap]::FromFile($srcPath)

$minX = $src.Width
$maxX = 0
$minY = $src.Height
$maxY = 0

for ($x = 0; $x -lt $src.Width; $x++) {
    for ($y = 0; $y -lt $src.Height; $y++) {
        $pixel = $src.GetPixel($x, $y)
        if ($pixel.A -gt 15) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

$cropW = $maxX - $minX + 1
$cropH = $maxY - $minY + 1
$cropRect = New-Object System.Drawing.Rectangle($minX, $minY, $cropW, $cropH)
$cropped = $src.Clone($cropRect, $src.PixelFormat)

# 1. Generate Splash UI Icons (drawable-*) - fitted to splash UI (95% fill)
$splashDensities = @{
    "drawable-mdpi" = 128
    "drawable-hdpi" = 192
    "drawable-xhdpi" = 256
    "drawable-xxhdpi" = 384
    "drawable-xxxhdpi" = 512
}

foreach ($dir in $splashDensities.Keys) {
    $sz = $splashDensities[$dir]
    $outDir = "C:\Code\GitHub\EasyPlayer\android\app\src\main\res\$dir"
    if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

    $splashBmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $g = [System.Drawing.Graphics]::FromImage($splashBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    $scale = ($sz * 0.95) / [Math]::Max($cropW, $cropH)
    $dW = [int]($cropW * $scale)
    $dH = [int]($cropH * $scale)
    $dX = [int](($sz - $dW) / 2)
    $dY = [int](($sz - $dH) / 2)
    $g.DrawImage($cropped, $dX, $dY, $dW, $dH)
    $g.Dispose()
    $splashBmp.Save("$outDir\splash_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $splashBmp.Dispose()
}

# 2. Generate App Launcher Icons (mipmap-*) - scaled to 64% to fit inside Android Adaptive Icon 66% safe zone
$launcherDensities = @{
    "mipmap-mdpi" = 108
    "mipmap-hdpi" = 162
    "mipmap-xhdpi" = 216
    "mipmap-xxhdpi" = 324
    "mipmap-xxxhdpi" = 432
}

foreach ($dir in $launcherDensities.Keys) {
    $sz = $launcherDensities[$dir]
    $outDir = "C:\Code\GitHub\EasyPlayer\android\app\src\main\res\$dir"
    if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

    $iconBmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $g = [System.Drawing.Graphics]::FromImage($iconBmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)

    # 64% scale ensures 100% of complete image is inside Android's 66% safe zone without clipping
    $scale = ($sz * 0.64) / [Math]::Max($cropW, $cropH)
    $dW = [int]($cropW * $scale)
    $dH = [int]($cropH * $scale)
    $dX = [int](($sz - $dW) / 2)
    $dY = [int](($sz - $dH) / 2)
    $g.DrawImage($cropped, $dX, $dY, $dW, $dH)
    $g.Dispose()
    $iconBmp.Save("$outDir\launcher_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Save("$outDir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Save("$outDir\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $iconBmp.Dispose()
}

$cropped.Dispose()
$src.Dispose()
Write-Host "App launcher and splash icons generated with 66% safe-zone scaling!"
