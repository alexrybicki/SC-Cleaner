===============================================
   STAR CITIZEN CACHE CLEANER v2.0
===============================================

This folder contains the complete Star Citizen Cache Cleaner toolkit with 
digital signing and automated launcher.

FILES IN THIS FOLDER:
====================

🔵 MAIN FILES (Use these):
--------------------------
• RunCacheCleaner.bat            - Smart launcher with automatic certificate handling
• StarCitizenCacheCleaner.ps1    - Main PowerShell script (digitally signed)
• PowerShellCodeSigning.cer      - Digital certificate for script verification


USAGE INSTRUCTIONS:
==================

🎯 EASIEST WAY - Double-click: RunCacheCleaner.bat
   This automatically:
   - Checks for trusted certificate
   - Installs certificate if needed
   - Runs the script with proper security settings

🔧 MANUAL PowerShell EXECUTION:
   Set-ExecutionPolicy RemoteSigned -Scope process; .\StarCitizenCacheCleaner.ps1

⚡ BYPASS MODE (if certificate issues):
   Set-ExecutionPolicy Bypass -Scope process; .\StarCitizenCacheCleaner.ps1

CERTIFICATE INFORMATION:
========================
• Certificate Subject: CN=PowerShell Code Signing (10 Year)
• Valid Until: August 17, 2035 (10 years)
• Purpose: Ensures script integrity and allows RemoteSigned execution

DISTRIBUTION:
============
To use on another computer, copy these 3 files:
1. RunCacheCleaner.bat
2. StarCitizenCacheCleaner.ps1  
3. PowerShellCodeSigning.cer

FEATURES:
========
✓ Moves cache folders to Recycle Bin (safe deletion)
✓ Supports -WhatIf (preview mode)
✓ Supports -Silent (automated mode)
✓ Progress indicators and detailed logging
✓ Digital signature verification
✓ Automatic certificate installation
✓ Cross-system portability

Created: August 17, 2025
Author: https://robertsspaceindustries.com/en/citizens/Xzor
