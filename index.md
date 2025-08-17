# Star Citizen Cache Cleaner v2.0

A complete toolkit for cleaning Star Citizen cache with digital signing and automated launcher functionality.

<img src="Screenshot 2025-08-17 124745.png" >

## 📥 Download

**[Download Star Citizen Cache Cleaner v2.0](https://sc.rybicki.dev/Star%20Citizen%20Cache%20Cleaner.zip)**

Get the complete toolkit including all necessary files and certificates.

## 🚀 Quick Start

**The easiest way to get started:** Simply double-click `RunCacheCleaner.bat`

This smart launcher automatically:
- ✅ Checks for trusted certificate
- ✅ Installs certificate if needed  
- ✅ Runs the script with proper security settings

## 📁 What's Included

### Main Files (Use These)
- **[RunCacheCleaner.bat](https://github.com/alexrybicki/SC-Cleaner/blob/main/RunCacheCleaner.bat)** - Smart launcher with automatic certificate handling
- **[StarCitizenCacheCleaner.ps1](https://github.com/alexrybicki/SC-Cleaner/blob/main/StarCitizenCacheCleaner.ps1)** - Main PowerShell script (digitally signed)
- **[PowerShellCodeSigning.cer](https://github.com/alexrybicki/SC-Cleaner/blob/main/PowerShellCodeSigning.cer)** - Digital certificate for script verification

## 🛠️ Advanced Usage

### Manual PowerShell Execution
```powershell
Set-ExecutionPolicy RemoteSigned -Scope process; .\StarCitizenCacheCleaner.ps1
```

### Bypass Mode (if certificate issues)
```powershell
Set-ExecutionPolicy Bypass -Scope process; .\StarCitizenCacheCleaner.ps1
```

## 🔐 Security & Certificate Information

- **Certificate Subject:** CN=PowerShell Code Signing (10 Year)
- **Valid Until:** August 17, 2035 (10 years)
- **Purpose:** Ensures script integrity and allows RemoteSigned execution

## ✨ Key Features

- **🗑️ Safe Deletion** - Moves cache folders to Recycle Bin instead of permanent deletion
- **👁️ Preview Mode** - Supports `-WhatIf` parameter to see what would be deleted
- **🤫 Silent Mode** - Supports `-Silent` parameter for automated execution
- **📊 Progress Tracking** - Visual progress indicators and detailed logging
- **🔒 Digital Signature** - Verified script integrity with certificate validation
- **⚙️ Auto-Install** - Automatic certificate installation for seamless operation
- **🔄 Portable** - Cross-system portability for easy distribution

## 📦 Distribution

To use on another computer, copy these 3 essential files:
1. `RunCacheCleaner.bat`
2. `StarCitizenCacheCleaner.ps1`  
3. `PowerShellCodeSigning.cer`

## 📝 About

- **Created:** August 17, 2025
- **Author:** [Xzor](https://robertsspaceindustries.com/en/citizens/Xzor)
- **Version:** 2.0
- **Github** [SC-Cleaner](https://github.com/alexrybicki/SC-Cleaner)

---

*Keep your Star Citizen installation running smoothly with automated cache management.*
