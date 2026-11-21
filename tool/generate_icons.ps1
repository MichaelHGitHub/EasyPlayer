Add-Type -AssemblyName System.Drawing

$sourcePath = "C:\Code\GitHub\EasyPlayer\artwork\Neon Panda Audio App Icon.png"
if (!(Test-Path $sourcePath)) {
    Write-Error "Source image not found at $sourcePath"
    exit 1
}

$srcImage = [System.Drawing.Image]::FromFile($sourcePath)

$sizes = [ordered]@{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($key in $sizes.Keys) {
    $dim = $sizes[$key]
    $targetDir = "C:\Code\GitHub\EasyPlayer\android\app\src\main\res\$key"
    if (!(Test-Path $targetDir)) {
        New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
    }

    # Save ic_launcher.png
    $destImage = New-Object System.Drawing.Bitmap($dim, $dim)
    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.DrawImage($srcImage, 0, 0, $dim, $dim)

    $outputPath = Join-Path $targetDir "ic_launcher.png"
    $destImage.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $destImage.Dispose()

    # Save ic_launcher_round.png
    $destImageRound = New-Object System.Drawing.Bitmap($dim, $dim)
    $graphicsRound = [System.Drawing.Graphics]::FromImage($destImageRound)
    $graphicsRound.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphicsRound.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphicsRound.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphicsRound.DrawImage($srcImage, 0, 0, $dim, $dim)

    $outputPathRound = Join-Path $targetDir "ic_launcher_round.png"
    $destImageRound.Save($outputPathRound, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphicsRound.Dispose()
    $destImageRound.Dispose()

    Write-Host "Generated icons for $key ($dim x $dim)"
}

$srcImage.Dispose()
Write-Host "Icons generation completed successfully!"
