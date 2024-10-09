$hostsFilePath = "C:\Windows\System32\drivers\etc\hosts"
$newEntry = "
127.0.0.1   instagram.com
127.0.0.1   www.instagram.com
127.0.0.1   www.tiktok.com
127.0.0.1   tiktok.com
127.0.0.1   www.snapchat.com
127.0.0.1   snapchat.com
"
Add-Content -Path $hostsFilePath -Value $newEntry
