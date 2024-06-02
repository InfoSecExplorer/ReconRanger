#!/bin/bash

clear
# Prompting user for domain input
echo -n -e "\e[34mEnter the domain (e.g., example.com): \e[0m"
read domain
echo

# Checking if the domain is provided
if [ -z "$domain" ]; then
  echo -e "\e[31mError: Domain not provided.\e[0m"
  exit 1
fi

# Create folder for the domain
folder="$domain"
mkdir -p "$folder"

# Running subfinder to find subdomains
echo -e "\e[32m~~~~~~~~ Running subfinder... ~~~~~~~~\e[0m"
subfinder -d "$domain" -o "$folder/sub1.txt"
echo

# Running assetfinder to find subdomains
echo -e "\e[32m~~~~~~~~ Running assetfinder... ~~~~~~~~\e[0m"
assetfinder -subs-only "$domain" | tee "$folder/sub2.txt"
echo

# Running findomain to find subdomains
echo -e "\e[32m~~~~~~~~ Running findomain... ~~~~~~~~\e[0m"
findomain -t "$domain" | tee "$folder/sub3.txt"
echo

# Merge all subdomains in one file
echo -e "\e[32m~~~~~~~~ Merging all Subdomains... ~~~~~~~~\e[0m"
cat "$folder/sub1.txt" "$folder/sub2.txt" "$folder/sub3.txt" | sort -u | tee "$folder/subdomains.txt"
echo

# Running httpx
echo -e "\e[32m~~~~~~~~ Finding Live Subdomains... ~~~~~~~~\e[0m"
httpx -l "$folder/subdomains.txt" | tee "$folder/live_subdomains.txt"
echo

# Subdomain Takeover Check
echo -e "\e[32m~~~~~~~~ Checking Subdomain Takeover Vulnerability... ~~~~~~~~\e[0m"
~/subzy/subzy run --targets "$folder/live_subdomains.txt"
echo

# Find Open Ports (increased connection limit)
echo -e "\e[32m~~~~~~~~ Finding Open Ports... ~~~~~~~~\e[0m"
sudo naabu -list "$folder/live_subdomains.txt" -c 100 -o "$folder/open_ports.txt"
echo

# Finding JSON Files
echo -e "\e[32m~~~~~~~~ Finding JSON files... ~~~~~~~~\e[0m"
httpx -l "$folder/live_subdomains.txt" | waybackurls | grep -E ".json(onp)?$"
echo

# Running Katana, subjs, httpx, nuclei
echo -e "\e[32m~~~~~~~~ Finding JavaScript file Vulnerabilities... ~~~~~~~~\e[0m"
cat "$folder/live_subdomains.txt" | katana | grep js | tee -a "$folder/js.txt"
cat "$folder/live_subdomains.txt" | subjs | grep js | tee -a "$folder/js.txt"
httpx -l "$folder/js.txt" | tee "$folder/live_js.txt"
nuclei -l "$folder/live_js.txt" -t ~/nuclei-templates/http/exposures/ -o "$folder/js_bugs.txt"
echo

# Running Dirsearch
echo -e "\e[32m~~~~~~~~ Finding Hidden directories... ~~~~~~~~\e[0m"
sudo dirsearch -e* -l "$folder/live_subdomains.txt" --deep-recursive --force-recursive --exclude-sizes=0B --random-agent --full-url -o "$folder/dirsearch.txt"
echo

# Find vulnerabilities using multiple tools
echo -e "\e[32m~~~~~~~~ Finding all Injection Vulnerabilities... ~~~~~~~~\e[0m"
waybackurls "$folder/live_subdomains.txt" | tee "$folder/urls.txt"
cat "$folder/urls.txt" | uro | sed 's/=.*/=/' | gf lfi | nuclei -dast
echo

# Find Local File Inclusion (LFI) Vulnerability
echo -e "\e[32m~~~~~~~~ Finding Local File Inclusion (LFI) Vulnerability... ~~~~~~~~\e[0m"
httpx -l "$folder/live_subdomains.txt" -path "///////../../../../../../etc/passwd" -status-code -mc 200 -ms 'root:'
echo

# Find Cross-Site Scripting (XSS) Vulnerabilities
echo -e "\e[32m~~~~~~~~ Finding Cross-Site Scripting (XSS) Vulnerabilities... ~~~~~~~~\e[0m"

echo "First method:"
gospider -S "$folder/live_subdomains.txt" -c 10 -d 5 --blacklist ".*(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" --other-source | grep -e "code-200" | awk '{print $5}' | grep "=" | qsreplace -a | dalfox pipe | tee "$folder/XSS.txt"
echo

echo "Second method:"
waybackurls "$domain" | grep '=' | qsreplace '"><script>alert(1)</script>' | while read host; do curl -sk --path-as-is "$host" | grep -qs "<script>alert(1)</script>" && echo "$host is vulnerable"; done
echo

# Find Open Redirection Vulnerability
echo -e "\e[32m~~~~~~~~ Finding Open Redirection Vulnerability... ~~~~~~~~\e[0m"
waybackurls "$domain" | grep -a -i =http | qsreplace 'http://evil.com' | while read host; do curl -s -L "$host" -I | grep "evil.com" && echo "$host \033[0;31mVulnerable\n"; done
echo

# Vulnerability Scanner using Nuclei
echo -e "\e[32m~~~~~~~~ Vulnerability Scanning Using Nuclei... ~~~~~~~~\e[0m"
nuclei -l "$folder/live_subdomains.txt" -o "$folder/nuclei_result.txt"
echo
