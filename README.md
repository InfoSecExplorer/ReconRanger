**Tool Description:**
* The automated script designed for comprehensive security assessments and reconnaissance of web domains. This tool leverages multiple powerful security tools to find and enumerate subdomains, check for live hosts, identify open ports, discover hidden directories, and test for various vulnerabilities including XSS, LFI, open redirections, and more.

**Usage:**
* git clone https://github.com/InfoSecExplorer/ReconRanger/ 
* cd ReconRanger
* chmod +x automated-recon
* ./automated-recon
* Then enter your target website.

**Features:**
* **Subdomain Enumeration:** Uses subfinder, assetfinder, and findomain to discover subdomains.
* **Live Subdomains:** Identifies live subdomains using httpx.
* **Subdomain Takeover:** Checks for potential subdomain takeovers using subzy.
* **Open Ports:** Finds open ports with naabu.
* **JSON Files Discovery:** Searches for JSON files in the web archive.
* **JavaScript Vulnerabilities:** Identifies potential vulnerabilities in JavaScript files using katana, subjs, httpx, and nuclei.
* **Directory Enumeration:** Discovers hidden directories using dirsearch.
* **Injection Vulnerabilities:** Finds injection vulnerabilities like LFI, CRLF, SQLi, and more with various tools.
* **Cross-Site Scripting (XSS):** Detects XSS vulnerabilities using gospider, qsreplace, and dalfox.
* **Open Redirection:** Identifies open redirection vulnerabilities.
* **Comprehensive Vulnerability Scanning:** Uses nuclei for detailed scanning of live subdomains.

**Prerequisites:**
* subfinder
* assetfinder
* findomain
* httpx
* subzy
* naabu
* waybackurls
* katana
* subjs
* nuclei
* dirsearch
* gospider
* qsreplace
* dalfox
* uro
* gf
