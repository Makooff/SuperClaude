const { app, BrowserWindow, ipcMain, shell } = require('electron')
const { exec, spawn } = require('child_process')
const path = require('path')

function createWindow() {
  const win = new BrowserWindow({
    width: 540,
    height: 680,
    frame: false,
    resizable: false,
    center: true,
    backgroundColor: '#0a0a0f',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  })
  win.loadFile('src/index.html')
}

app.whenReady().then(createWindow)
app.on('window-all-closed', () => app.quit())

// IPC handlers
ipcMain.handle('run-command', async (event, command) => {
  return new Promise((resolve) => {
    exec(command, { timeout: 30000 }, (error, stdout, stderr) => {
      resolve({
        success: !error,
        stdout: stdout?.trim(),
        stderr: stderr?.trim(),
        error: error?.message
      })
    })
  })
})

ipcMain.handle('open-claude', async () => {
  const platform = process.platform
  if (platform === 'darwin') {
    exec('open -a "Claude"', (err) => {
      if (err) exec('claude', () => {})
    })
  } else if (platform === 'win32') {
    exec('start claude', () => {})
  } else {
    exec('claude', () => {})
  }
})

ipcMain.on('close-app', () => app.quit())
ipcMain.on('minimize-app', (event) => {
  BrowserWindow.fromWebContents(event.sender).minimize()
})
