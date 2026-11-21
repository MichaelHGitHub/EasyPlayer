Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Code\GitHub\EasyPlayer\artwork\logo_transparent.png"
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

$densities = @{
    "drawable-mdpi" = 128
    "drawable-hdpi" = 192
    "drawable-xhdpi" = 256
    "drawable-xxhdpi" = 384
    "drawable-xxxhdpi" = 512
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($dir in $densities.Keys) {
    $sz = $densities[$dir]
    $outDir = "C:\Code\GitHub\EasyPlayer\android\app\src\main\res\$dir"
    if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

    # Splash Icon: logo fills 92% of bounds cleanly
    $splashBmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $g1 = [System.Drawing.Graphics]::FromImage($splashBmp)
    $g1.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g1.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g1.Clear([System.Drawing.Color]::Transparent)

    $scale1 = ($sz * 0.92) / [Math]::Max($cropW, $cropH)
    $dW1 = [int]($cropW * $scale1)
    $dH1 = [int]($cropH * $scale1)
    $dX1 = [int](($sz - $dW1) / 2)
    $dY1 = [int](($sz - $dH1) / 2)
    $g1.DrawImage($cropped, $dX1, $dY1, $dW1, $dH1)
    $g1.Dispose()
    $splashBmp.Save("$outDir\splash_icon.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $splashBmp.Dispose()

    # Launcher Foreground: logo fills 82% of bounds cleanly
    $fgBmp = New-Object System.Drawing.Bitmap($sz, $sz)
    $g2 = [System.Drawing.Graphics]::FromImage($fgBmp)
    $g2.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g2.Clear([System.Drawing.Color]::Transparent)

    $scale2 = ($sz * 0.82) / [Math]::Max($cropW, $cropH)
    $dW2 = [int]($cropW * $scale2)
    $dH2 = [int]($cropH * $scale2)
    $dX2 = [int](($sz - $dW2) / 2)
    $dY2 = [int](($sz - $dH2) / 2)
    $g2.DrawImage($cropped, $dX2, $dY2, $dW2, $dH2)
    $g2.Dispose()
    $fgBmp.Save("$outDir\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $fgBmp.Dispose()
}

$cropped.Dispose()
$src.Dispose()
Write-Host "Icons updated successfully!"
