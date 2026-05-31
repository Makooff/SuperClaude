#!/usr/bin/env node
// Always-on skill router — runs on every UserPromptSubmit
// Outputs imperative instruction Claude must follow before responding

const fs = require('fs')
const path = require('path')

const chunks = []
process.stdin.on('data', c => chunks.push(c))
process.stdin.on('end', () => {
  let input = {}
  try { input = JSON.parse(Buffer.concat(chunks)) } catch {}

  const msg = (input.message || '').toLowerCase()
  const projectDir = process.env.CLAUDE_PROJECT_DIR || process.cwd()

  // Load project learnings if available
  let learnings = ''
  try {
    const lp = path.join(projectDir, '.claude', 'learnings.md')
    if (fs.existsSync(lp)) learnings = fs.readFileSync(lp, 'utf8')
  } catch {}

  // Semantic task classification — intent-based, not keyword-based
  const tasks = classify(msg)
  const lines = []

  if (tasks.length) {
    lines.push('⚡ SKILLS REQUIS — invoquer AVANT de répondre:')
    tasks.forEach(t => lines.push(`  → ${t.skill}  [${t.reason}]`))
    lines.push('Ne pas répondre sans avoir invoqué ces skills.')
  }

  // Inject accumulated learnings snippet
  if (learnings) {
    const snippet = extractLearningsSnippet(learnings)
    if (snippet) {
      lines.push('')
      lines.push('📚 LEARNINGS PROJET (applique-les):')
      lines.push(snippet)
    }
  }

  if (lines.length) console.log(lines.join('\n'))
})

function classify(msg) {
  const tasks = []

  // Design / UI — broad semantic net
  if (/design|ui|ux|page|layout|composant|component|landing|hero|section|card|button|form|nav|sidebar|dashboard|animation|transition|couleur|color|font|typo|icon|style|theme|dark|light|responsive|mobile|visual|interface|écran|screen|figma|sketch/.test(msg)) {
    tasks.push({ skill: 'Skill(impeccable) + Skill(taste-skill) + Skill(emil-design-eng)', reason: 'tâche UI/design détectée' })
  }

  // Code review / quality
  if (/review|audit|qualit|refactor|clean|améliore|optimis|simplif|revu|inspect|analys/.test(msg) && !/design/.test(msg)) {
    tasks.push({ skill: 'Skill(code-review)', reason: 'revue/optimisation code' })
  }

  // Testing
  if (/test|tdd|spec|coverage|jest|vitest|playwright|cypress|unit|intégration|e2e/.test(msg)) {
    tasks.push({ skill: 'Skill(tdd-workflow)', reason: 'tâche test détectée' })
  }

  // Debug / fix
  if (/debug|bug|crash|error|erreur|broken|fix|cass|plante|fail|issue|probl[eè]me|ne fonctionne|marche pas/.test(msg)) {
    tasks.push({ skill: 'Skill(systematic-debugging)', reason: 'débogage détecté' })
  }

  // Security
  if (/s[eé]curit|auth|token|password|mot de passe|api.?key|secret|jwt|oauth|permission|inject|xss|csrf|vuln/.test(msg)) {
    tasks.push({ skill: 'Skill(security)', reason: 'contexte sécurité détecté' })
  }

  // Planning / architecture
  if (/plan|architectur|feature|fonctionnalit|roadmap|comment impl|comment faire|comment cr[eé]er|structur|syst[eè]me|conception|design pattern/.test(msg)) {
    tasks.push({ skill: 'Skill(writing-plans) + Skill(executing-plans)', reason: 'conception/planification' })
  }

  // Verification / deploy
  if (/v[eé]rif|check|qa|deploy|ci|cd|build|lint|test.*avant|avant.*push|pr[eê]t|ready/.test(msg)) {
    tasks.push({ skill: 'Skill(verify)', reason: 'vérification/déploiement' })
  }

  // New feature (no other category matched)
  if (tasks.length === 0 && /cr[eé]e|ajoute|impl[eé]mente|construit|fais|génère|nouveau|nouvelle|build|make|add/.test(msg)) {
    tasks.push({ skill: 'Skill(writing-plans)', reason: 'nouvelle fonctionnalité — plan requis' })
  }

  return tasks
}

function extractLearningsSnippet(md) {
  // Extract last 15 lines of learnings, skip headers
  const lines = md.split('\n')
    .filter(l => l.trim() && !l.startsWith('#'))
    .slice(-15)
  return lines.join('\n')
}
