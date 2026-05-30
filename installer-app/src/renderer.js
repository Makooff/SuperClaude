// ============================================================
//  SuperClaude Installer — renderer.js
// ============================================================

const api = window.api

// --- State ---
let currentScreen = 1
let magicKey = ''
let obsidianKey = ''
let openAfterInstall = true
let checksOk = false

// --- DOM helpers ---
const $ = (id) => document.getElementById(id)

// ============================================================
//  Screen transitions
// ============================================================
function goTo(screenNum) {
  const current = $(`screen-${currentScreen}`)
  const next = $(`screen-${screenNum}`)

  current.classList.add('exit-left')
  current.classList.remove('active')

  setTimeout(() => {
    current.classList.remove('exit-left')
  }, 350)

  // Small delay so the exit animation starts first
  setTimeout(() => {
    next.classList.add('active')
    currentScreen = screenNum
  }, 50)
}

// ============================================================
//  Title bar controls
// ============================================================
$('btn-close').addEventListener('click', () => api.close())
$('btn-minimize').addEventListener('click', () => api.minimize())

// ============================================================
//  Screen 1 — Welcome
// ============================================================
$('btn-start').addEventListener('click', () => {
  goTo(2)
  runChecks()
})

// ============================================================
//  Screen 2 — Prerequisites
// ============================================================
const CHECKS = [
  {
    id: 'node',
    name: 'Node.js',
    cmd: 'node --version',
    parse: (out) => {
      if (!out) return { ok: false, detail: 'non détecté' }
      const match = out.match(/v(\d+)/)
      if (!match) return { ok: false, detail: 'version inconnue' }
      const major = parseInt(match[1])
      return major >= 18
        ? { ok: true, detail: out }
        : { ok: false, detail: `v${major} — Node.js 18+ requis` }
    },
    linkId: 'link-node'
  },
  {
    id: 'claude',
    name: 'Claude Code',
    cmd: 'claude --version',
    parse: (out, err) => {
      // claude --version might output to stderr on some versions
      const combined = out || err || ''
      if (combined.includes('claude') || combined.match(/\d+\.\d+/)) {
        return { ok: true, detail: combined.split('\n')[0] || 'détecté' }
      }
      return { ok: false, detail: 'non détecté' }
    },
    linkId: 'link-claude'
  }
]

async function runChecks() {
  const list = $('checks-list')
  list.innerHTML = ''

  let allOk = true

  for (const check of CHECKS) {
    // Create item with spinner
    const item = document.createElement('div')
    item.className = 'check-item'
    item.id = `check-item-${check.id}`
    item.innerHTML = `
      <div class="check-status pending" id="check-status-${check.id}">
        <div class="spinner"></div>
      </div>
      <div class="check-info">
        <div class="check-name">${check.name}</div>
        <div class="check-detail" id="check-detail-${check.id}">Vérification...</div>
      </div>
    `
    list.appendChild(item)

    // Run check
    await new Promise(resolve => setTimeout(resolve, 300))
    const result = await api.runCommand(check.cmd)
    const parsed = check.parse(result.stdout, result.stderr)

    // Update item
    const statusEl = $(`check-status-${check.id}`)
    const detailEl = $(`check-detail-${check.id}`)
    const itemEl = $(`check-item-${check.id}`)

    if (parsed.ok) {
      statusEl.innerHTML = '✓'
      statusEl.className = 'check-status success'
      itemEl.classList.add('success')
      detailEl.textContent = parsed.detail
    } else {
      statusEl.innerHTML = '✗'
      statusEl.className = 'check-status error'
      itemEl.classList.add('error')
      detailEl.textContent = parsed.detail
      allOk = false
      // Show relevant link
      if (check.linkId) {
        const linkEl = $(check.linkId)
        if (linkEl) linkEl.style.display = 'flex'
      }
    }
  }

  checksOk = allOk

  if (allOk) {
    // Auto-advance
    await new Promise(resolve => setTimeout(resolve, 800))
    goTo(3)
  } else {
    $('prereq-links').classList.add('visible')
    const actionsEl = $('prereq-actions')
    actionsEl.style.display = 'flex'
  }
}

$('btn-retry').addEventListener('click', () => {
  $('prereq-links').classList.remove('visible')
  $('prereq-actions').style.display = 'none'
  $('link-node').style.display = 'none'
  $('link-claude').style.display = 'none'
  runChecks()
})

$('btn-skip-prereq').addEventListener('click', () => goTo(3))

// ============================================================
//  Screen 3 — Configuration
// ============================================================
$('btn-install').addEventListener('click', () => {
  magicKey = $('input-magic-key').value.trim()
  obsidianKey = $('input-obsidian-key').value.trim()
  openAfterInstall = $('check-open-claude').checked
  goTo(4)
  runInstallation()
})

$('btn-skip-config').addEventListener('click', () => {
  magicKey = ''
  obsidianKey = ''
  openAfterInstall = false
  goTo(4)
  runInstallation()
})

// Allow clicking checkbox group label area to toggle
$('checkbox-group').addEventListener('click', (e) => {
  if (e.target.tagName !== 'INPUT') {
    const cb = $('check-open-claude')
    cb.checked = !cb.checked
  }
})

// ============================================================
//  Screen 4 — Installation
// ============================================================

function logLine(text, type = 'success') {
  const logArea = $('log-area')
  const line = document.createElement('span')
  line.className = `log-line ${type}`
  line.textContent = text
  logArea.appendChild(line)
  logArea.appendChild(document.createElement('br'))
  logArea.scrollTop = logArea.scrollHeight
}

function setProgress(percent, label) {
  $('progress-bar').style.width = percent + '%'
  $('step-percent').textContent = percent + '%'
  $('step-label').textContent = label
}

function buildSteps() {
  const steps = [
    {
      label: 'Vérification de l\'environnement',
      fake: 800,
      cmd: null
    },
    {
      label: 'Installation plugin code-review',
      cmd: 'claude plugin install code-review'
    },
    {
      label: 'Installation plugin superpowers',
      cmd: 'claude plugin install superpowers'
    },
    {
      label: 'Installation plugin impeccable',
      cmd: 'claude plugin install impeccable'
    },
    {
      label: 'Installation plugin taste-skill',
      cmd: 'claude plugin install taste-skill'
    },
    {
      label: 'Installation plugin playwright',
      cmd: 'claude plugin install playwright'
    },
    {
      label: 'Configuration MCP context7',
      cmd: 'claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp'
    },
    {
      label: 'Configuration MCP playwright',
      cmd: 'claude mcp add playwright --scope user -- npx @playwright/mcp@latest'
    }
  ]

  // MCP magic — only if key provided
  if (magicKey) {
    steps.push({
      label: 'Configuration MCP magic',
      cmd: `claude mcp add magic --scope user --env API_KEY="${magicKey}" -- npx -y @21st-dev/magic@latest`
    })
  }

  steps.push({
    label: 'Finalisation...',
    fake: 600,
    cmd: null
  })

  return steps
}

async function runInstallation() {
  const steps = buildSteps()
  const total = steps.length
  let installErrors = 0

  logLine('› Démarrage installation SuperClaude', 'info')

  for (let i = 0; i < steps.length; i++) {
    const step = steps[i]
    const percent = Math.round(((i) / total) * 100)

    setProgress(percent, step.label)
    logLine(``)
    logLine(`[${i + 1}/${total}] ${step.label}`, 'info')

    if (step.fake) {
      // Simulate delay
      logLine('  ✓ OK', 'success')
      await sleep(step.fake)
    } else if (step.cmd) {
      logLine(`  $ ${step.cmd}`, 'info')

      const result = await api.runCommand(step.cmd)

      if (result.stdout) {
        result.stdout.split('\n').forEach(line => {
          if (line.trim()) logLine(`  ${line}`, 'success')
        })
      }

      if (result.stderr) {
        result.stderr.split('\n').forEach(line => {
          if (line.trim()) {
            // stderr is not always an error (npm uses it for progress)
            const isErr = result.success === false
            logLine(`  ${line}`, isErr ? 'error' : 'warning')
          }
        })
      }

      if (result.success) {
        logLine(`  ✓ Terminé`, 'success')
      } else {
        logLine(`  ✗ Erreur: ${result.error || 'commande échouée'}`, 'error')
        installErrors++
      }

      // Small pause between commands
      await sleep(200)
    }
  }

  // Final progress
  setProgress(100, 'Installation terminée !')
  await sleep(500)

  if (installErrors > 0) {
    logLine(``, 'info')
    logLine(`Installation terminée avec ${installErrors} erreur(s).`, 'warning')
    logLine(`Certaines commandes ont échoué — vérifiez les logs ci-dessus.`, 'warning')
  } else {
    logLine(``, 'info')
    logLine(`✓ SuperClaude installé avec succès !`, 'success')
  }

  await sleep(800)

  // Open Claude if requested
  if (openAfterInstall) {
    await api.openClaude()
    await sleep(300)
  }

  goTo(5)
  // Restart checkmark animation by re-appending the SVG strokes
  triggerCheckmarkAnimation()
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms))
}

// ============================================================
//  Screen 5 — Done
// ============================================================

function triggerCheckmarkAnimation() {
  // Re-trigger by removing and re-adding animation class
  const circle = document.querySelector('.checkmark-circle')
  const path = document.querySelector('.checkmark-path')

  if (circle && path) {
    // Reset
    circle.style.animation = 'none'
    path.style.animation = 'none'
    // Force reflow
    void circle.offsetWidth
    // Re-apply
    circle.style.animation = ''
    path.style.animation = ''
  }
}

$('btn-open-claude').addEventListener('click', async () => {
  await api.openClaude()
  setTimeout(() => api.close(), 500)
})

$('btn-close-done').addEventListener('click', () => api.close())
