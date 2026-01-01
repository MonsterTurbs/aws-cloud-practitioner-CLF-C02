$root = "C:\Users\reymo\OneDrive\Desktop\AWS Certified Cloud Practitioner CLF C02"

# 1) Backup all HTML files first
$stamp  = Get-Date -Format "yyyyMMdd_HHmmss"
$backup = Join-Path $root ("_backup_html_before_header_" + $stamp)

New-Item -ItemType Directory -Force -Path $backup | Out-Null

Get-ChildItem -LiteralPath $root -Recurse -Filter *.html | ForEach-Object {
    $rel  = $_.FullName.Substring($root.Length).TrimStart('\')
    $dest = Join-Path $backup $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
}

# 2) Header block to inject (as an HTML comment)
$header = @"
   
Create a print-friendly HTML page from the lecture/transcript I will provide.
Convert the content into a reviewer / study guide with beginner-friendly explanations and examples where appropriate.
Include icons and emoticons to improve readability and retention.
Use a white background and ensure the page is A4 print-ready for standard white bond paper.
Use a single-column layout only.
Ensure word wrapping and spacing so that text does not get cut off when printed.
Include print-specific CSS (margins, font sizing, line height) for clean print output.
 
"@

# 3) Inject header into every .html file (once only)
Get-ChildItem -LiteralPath $root -Recurse -Filter *.html | ForEach-Object {
    $path = $_.FullName
    $content = Get-Content -Raw -LiteralPath $path

    # Skip if already injected
    if ($content -match 'AWS-REVIEWER-HEADER-START') { return }

    # If doctype exists, insert AFTER doctype; otherwise prepend header
    if ($content -match '(?im)^(<!doctype\s+html\s*>\s*)') {
        $newContent = [regex]::Replace(
            $content,
            '(?im)^(<!doctype\s+html\s*>\s*)',
            "`$1`r`n$header`r`n",
            1
        )
    }
    else {
        $newContent = "$header`r`n$content"
    }

    Set-Content -LiteralPath $path -Encoding UTF8 -Value $newContent
}

Write-Host "DONE."
Write-Host "Backup created at: $backup"
