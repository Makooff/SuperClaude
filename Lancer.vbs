Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")
strDir = objFSO.GetParentFolderName(WScript.ScriptFullName)
strCmd = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -File """ & strDir & "\SuperClaude-Installer.ps1"""
objShell.Run strCmd, 0, False
