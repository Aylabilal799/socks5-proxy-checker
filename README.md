# SOCKS5 Proxy Checker (Windows)

A fast and accurate SOCKS5 proxy checker for Windows.

This tool tests a list of proxies and **only saves the ones that are really working** (can successfully connect to the internet through the proxy).

---

## Features

- Multi-threaded (100 concurrent connections)
- Full SOCKS5 protocol test (not just port open)
- Real connectivity test through the proxy to `1.1.1.1:80` (Cloudflare)
- Only saves real working proxies in `working.txt`
- Shows live progress while scanning
- Completely standalone (just double-click)
- No extra software required

---

## How to Use

1. Download `check_socks5.bat`
2. Create a file named `IPs.txt` in the same folder
3. Put your proxies inside `IPs.txt` (one per line)
4. Double-click `check_socks5.bat`
5. Wait for the scan to finish

### Example of `IPs.txt`:

```
72.245.206.164:2000
84.75.54.251:42012
31.58.139.115:42005
1.2.3.4:1080
5.6.7.8:1080
```

---

## Results

After the scan is completed, you will get two files:

| File              | Description                                      |
|-------------------|--------------------------------------------------|
| `working.txt`     | Only real working proxies (recommended to use)  |
| `results_log.txt` | Full detailed log of every tested proxy         |

---

## Settings

| Setting          | Value                  |
|------------------|------------------------|
| Concurrent Threads | 100                  |
| Timeout per proxy  | 10 seconds           |
| Test Target        | 1.1.1.1:80 (Cloudflare) |
| Authentication     | No-Auth only         |

---

## Requirements

- Windows 10 or Windows 11
- PowerShell (already included in Windows)

No need to install anything extra.

---

## How the Checking Works

The tool performs a full SOCKS5 test:

1. Connects to the proxy IP and port
2. Sends SOCKS5 greeting (No Authentication)
3. Sends a `CONNECT` request to `1.1.1.1:80`
4. Only marks the proxy as **LIVE** if the connection through the proxy succeeds

This method is much more accurate than just checking if the port is open.

---

## Notes

- Many public SOCKS5 lists contain proxies that require username + password. This tool only detects **open (no-auth)** working proxies.
- The more proxies you test, the longer the scan will take.
- Dead, filtered, or authentication-required proxies will not be saved in `working.txt`.

---

## Disclaimer

This tool is provided for educational and legitimate testing purposes only.  
Use it only on proxies that you own or have explicit permission to test.  
The developer is not responsible for any misuse of this tool.

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
