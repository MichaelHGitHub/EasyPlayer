$resDir = "C:\Code\GitHub\EasyPlayer\android\app\src\main\res"

# Remove backup directories and unused drawable density folders
$dirsToRemove = @(
    "$resDir\bak",
    "$resDir\drawable-hdpi",
    "$resDir\drawable-mdpi",
    "$resDir\drawable-xhdpi",
    "$resDir\drawable-xxhdpi",
    "$resDir\drawable-xxxhdpi"
)

foreach ($dir in $dirsToRemove) {
    if (Test-Path $dir) {
        Remove-Item -Recurse -Force $dir
        Write-Host "Removed directory: $dir"
    }
}

# Remove any nested bak directories
Get-ChildItem -Recurse -Path $resDir -Directory -Filter "bak" | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
    Write-Host "Removed nested bak directory: $($_.FullName)"
}

# Remove unused file names
$unusedFiles = @(
    "launcher_icon.xml",
    "launcher_icon.png",
    "splash_icon.png",
    "ic_launcher_foreground.png"
)

foreach ($fileName in $unusedFiles) {
    Get-ChildItem -Recurse -Path $resDir -Filter $fileName | ForEach-Object {
        Remove-Item -Force $_.FullName
        Write-Host "Removed unused file: $($_.FullName)"
    }
}

Write-Host "Res cleanup completed!"
