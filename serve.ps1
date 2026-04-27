# Turno Player — servidor local PowerShell
# Sirve la carpeta actual en http://127.0.0.1:8080/
# No requiere Python ni Node. Solo PowerShell (viene con Windows).

$ErrorActionPreference = "Stop"
$port = 8080
$root = $PSScriptRoot
$prefix = "http://127.0.0.1:$port/"

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)

try {
    $listener.Start()
} catch {
    Write-Host "ERROR: No se pudo abrir el puerto $port. Puede que ya este en uso." -ForegroundColor Red
    Write-Host "Probá editar este archivo y cambiar `$port = 8080` por otro puerto (ej. 8888)." -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  TURNO PLAYER - servidor local activo" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "URL: $prefix" -ForegroundColor Cyan
Write-Host "Carpeta servida: $root" -ForegroundColor Gray
Write-Host ""
Write-Host "IMPORTANTE - Redirect URI en Spotify Dashboard:" -ForegroundColor Yellow
Write-Host "  $prefix" -ForegroundColor Yellow
Write-Host ""
Write-Host "Para detener el servidor: cerra esta ventana o Ctrl+C" -ForegroundColor Gray
Write-Host ""

# Abrir browser automaticamente
Start-Process $prefix

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".htm"  = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".mp3"  = "audio/mpeg"
    ".wav"  = "audio/wav"
    ".ogg"  = "audio/ogg"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".jpeg" = "image/jpeg"
    ".gif"  = "image/gif"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
    ".md"   = "text/markdown; charset=utf-8"
    ".txt"  = "text/plain; charset=utf-8"
    ".woff" = "font/woff"
    ".woff2"= "font/woff2"
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
    } catch {
        break
    }
    $req = $context.Request
    $res = $context.Response

    try {
        $path = [System.Uri]::UnescapeDataString($req.Url.LocalPath).TrimStart('/').Replace('/', [IO.Path]::DirectorySeparatorChar)
        if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }

        $file = Join-Path $root $path
        # Seguridad: no salir de la carpeta root
        $fullRoot = [IO.Path]::GetFullPath($root)
        $fullFile = [IO.Path]::GetFullPath($file)
        if (-not $fullFile.StartsWith($fullRoot)) {
            $res.StatusCode = 403
            $msg = [Text.Encoding]::UTF8.GetBytes("403 Forbidden")
            $res.OutputStream.Write($msg, 0, $msg.Length)
        } elseif (Test-Path $fullFile -PathType Leaf) {
            $bytes = [IO.File]::ReadAllBytes($fullFile)
            $ext = [IO.Path]::GetExtension($fullFile).ToLower()
            $res.ContentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
            $res.ContentLength64 = $bytes.Length
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            $ts = (Get-Date).ToString("HH:mm:ss")
            Write-Host "[$ts] 200 $path" -ForegroundColor DarkGray
        } else {
            $res.StatusCode = 404
            $msg = [Text.Encoding]::UTF8.GetBytes("404 Not Found: $path")
            $res.OutputStream.Write($msg, 0, $msg.Length)
            Write-Host "[$(Get-Date -Format HH:mm:ss)] 404 $path" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    } finally {
        try { $res.Close() } catch {}
    }
}

$listener.Stop()
