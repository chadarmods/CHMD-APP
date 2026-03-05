$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://*:$port/")
try {
    $listener.Start()
}
catch {
    Write-Host "Failed to bind to http://*:$port/. Try running as Administrator to allow network access, or change port."
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    Write-Host "Started on localhost only. For network access, run as Admin."
}

Write-Host "Server listening on port $port"
$ip = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address.IPAddressToString
Write-Host "To test on your Android device locally, connect to the same Wi-Fi and open: http://$ip`:$port/"
Write-Host "Press Ctrl+C to stop."

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = $request.Url.LocalPath
        if ($path -eq "/") { $path = "/index.html" }
        $file = Join-Path $PWD.Path $path
        
        if (Test-Path $file -PathType Leaf) {
            try {
                $content = [System.IO.File]::ReadAllBytes($file)
                $response.ContentLength64 = $content.Length
                
                if ($file -match "\.html$") { $response.ContentType = "text/html" }
                elseif ($file -match "\.js$") { $response.ContentType = "application/javascript" }
                elseif ($file -match "\.json$") { $response.ContentType = "application/json" }
                elseif ($file -match "\.png$") { $response.ContentType = "image/png" }
                
                $response.OutputStream.Write($content, 0, $content.Length)
                Write-Host "200 $path"
            }
            catch {
                $response.StatusCode = 500
                Write-Host "500 Error reading $path"
            }
        }
        else {
            $response.StatusCode = 404
            Write-Host "404 $path not found"
        }
        $response.Close()
    }
}
finally {
    $listener.Stop()
}
