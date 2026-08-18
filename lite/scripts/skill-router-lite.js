#!/usr/bin/env node
// SuperClaude Lite — router d'intention.
// Ne propose QUE des skills réellement présents sur le disque : pas de skill fantôme.
// Silencieux quand rien ne matche (0 token). Max 3 lignes en sortie.

const fs = require('fs')
const path = require('path')
const os = require('os')

const HOME = os.homedir()
const PROJECT = process.env.CLAUDE_PROJECT_DIR || process.cwd()
const MAX_LINES = 3

// --- Catalogue : nom affiché -> skills candidats + MCP associé ---------------
// L'ordre du tableau EST l'ordre de priorité (tie-break).
const CATALOG = [
  { key: 'security',  re: /s[ée]curit|auth|jwt|oauth|token|secret|api.?key|mot de passe|password|xss|csrf|injection|vuln|cors|permission/,
    skills: ['security'], reason: 'sécurité' },

  { key: 'debug',     re: /debug|bug|crash|erreur|error|stack ?trace|ne fonctionne pas|marche pas|plante|r[ée]gression|fail/,
    skills: ['systematic-debugging'], reason: 'debug' },

  { key: 'design',    re: /design|ui\b|ux\b|maquette|wireframe|landing|hero\b|layout|composant|component|onboarding|dashboard|typograph|palette|responsive|interface|[ée]cran/,
    skills: ['product-design', 'impeccable', 'taste-skill'], mcp: 'magic', reason: 'design/UI' },

  { key: 'animation', re: /animation|motion|transition|easing|micro-?interaction|framer|spring|hover|feel(s)? (weird|off|good)/,
    skills: ['emil-design-eng', 'review-animations'], reason: 'motion' },

  { key: 'review',    re: /review|revue|audit|refactor|relis|relire|optimis|simplifi|qualit[ée] du code/,
    skills: ['code-review', 'receiving-code-review'], reason: 'revue code' },

  { key: 'tests',     re: /\btest|tdd|coverage|spec\b|jest|vitest|cypress|playwright|e2e/,
    skills: ['tdd-workflow', 'test-driven-development'], mcp: 'playwright', reason: 'tests' },

  { key: 'plan',      re: /architectur|roadmap|conception|comment impl[ée]ment|plan\b|d[ée]coupe|brainstorm/,
    skills: ['writing-plans', 'executing-plans', 'brainstorming'], reason: 'plan' },

  { key: 'verify',    re: /v[ée]rifi|avant (de )?(push|commit|merge)|pr[êe]t [àa] (livrer|push)|qa\b|production-?ready/,
    skills: ['verification-before-completion', 'agentic-practice'], reason: 'vérif avant livraison' },

  { key: 'orchestr',  re: /orchestr|multi-?agent|d[ée]compose|audit exhaustif|migration|grande [ée]chelle/,
    skills: ['context-engineering'], reason: 'orchestration' },

  { key: 'docs',      re: /comment (utiliser|marche|fonctionne)|documentation de|docs? de|version de|api de\b/,
    skills: [], mcp: 'context7', reason: 'doc lib' },
]

// --- Ce qui est réellement installé -----------------------------------------
function dirsWithSkill(root, depth) {
  const out = []
  if (!root || !fs.existsSync(root)) return out
  let entries
  try { entries = fs.readdirSync(root, { withFileTypes: true }) } catch { return out }
  for (const e of entries) {
    if (!e.isDirectory()) continue
    const p = path.join(root, e.name)
    if (fs.existsSync(path.join(p, 'SKILL.md'))) out.push(e.name)
    else if (depth > 0) out.push(...dirsWithSkill(p, depth - 1))
  }
  return out
}

function installedSkills() {
  const s = new Set()
  const add = a => a.forEach(n => s.add(n))
  add(dirsWithSkill(path.join(HOME, '.claude', 'skills'), 1))
  add(dirsWithSkill(path.join(PROJECT, '.claude', 'skills'), 1))
  // plugins : ~/.claude/plugins/cache/<marketplace>/<plugin>/skills/<skill>/SKILL.md
  const cache = path.join(HOME, '.claude', 'plugins', 'cache')
  if (fs.existsSync(cache)) {
    for (const mk of safeDirs(cache)) {
      for (const pl of safeDirs(path.join(cache, mk))) {
        add(dirsWithSkill(path.join(cache, mk, pl, 'skills'), 0))
      }
    }
  }
  return s
}

function safeDirs(p) {
  try { return fs.readdirSync(p, { withFileTypes: true }).filter(d => d.isDirectory()).map(d => d.name) }
  catch { return [] }
}

function installedMcp() {
  const s = new Set()
  for (const f of [path.join(HOME, '.claude.json'), path.join(PROJECT, '.mcp.json')]) {
    try { Object.keys(JSON.parse(fs.readFileSync(f, 'utf8')).mcpServers || {}).forEach(k => s.add(k)) } catch {}
  }
  return s
}

// --- Main --------------------------------------------------------------------
const chunks = []
process.stdin.on('data', c => chunks.push(c))
process.stdin.on('end', () => {
  let input = {}
  try { input = JSON.parse(Buffer.concat(chunks).toString('utf8')) } catch {}
  const msg = String(input.prompt || input.message || '').toLowerCase()
  if (!msg) return

  const matched = CATALOG.filter(c => c.re.test(msg))
  if (!matched.length) return

  const skills = installedSkills()
  const mcps = installedMcp()
  const lines = []

  for (const c of matched) {
    const have = c.skills.filter(n => skills.has(n))
    const mcpOn = c.mcp && mcps.has(c.mcp)
    const mcpOff = c.mcp && !mcpOn
    if (!have.length && !mcpOn && !mcpOff) continue
    if (!have.length && !c.mcp) continue

    const parts = []
    if (have.length) parts.push(have.map(n => `Skill(${n})`).join(' + '))
    if (mcpOn) parts.push(`MCP ${c.mcp}`)
    if (mcpOff) parts.push(`MCP ${c.mcp} absent → \`sc-mcp ${c.mcp} on\``)
    lines.push(`  → ${parts.join(' · ')}  [${c.reason}]`)
    if (lines.length >= MAX_LINES) break
  }

  if (!lines.length) return
  console.log('⚡ ' + (lines.length > 1 ? 'PERTINENT ici' : 'REQUIS') + ' — invoquer avant de répondre:')
  console.log(lines.join('\n'))
})
