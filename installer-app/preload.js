const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('api', {
  runCommand: (cmd) => ipcRenderer.invoke('run-command', cmd),
  openClaude: () => ipcRenderer.invoke('open-claude'),
  close: () => ipcRenderer.send('close-app'),
  minimize: () => ipcRenderer.send('minimize-app'),
  platform: process.platform
})
