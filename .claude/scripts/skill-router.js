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
    const header = tasks.length >= 3
      ? '⚡ SKILLS DISPONIBLES — chacun dans son rôle, invoquer ceux qui s\'appliquent:'
      : '⚡ SKILLS REQUIS — invoquer AVANT de répondre:'
    lines.push(header)
    tasks.forEach(t => lines.push(`  → ${t.skill}  [${t.reason}]`))
    lines.push('Combiner les skills (pas de doublon) : chaque skill a un rôle distinct.')
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

// Priority order for tie-break when many categories match.
// Lower index = higher priority (listed first in output).
const PRIORITY = [
  'security', 'debug', 'product-design', 'design', 'animation', 'review',
  'nova', 'research', 'marketing', 'prose', 'multiagent', 'video',
  'tests', 'plan', 'agentic', 'verify', 'feature',
]

function classify(msg) {
  const hits = {}
  const add = (key, skill, reason) => { hits[key] = { key, skill, reason } }

  // Product design (Vercel) — hub for user-facing product work
  if (/product design|design review|revoir (le )?design|user experience|onboarding|settings page|dashboard|flow|parcours|usability|maquette|wireframe/.test(msg)) {
    add('product-design', 'Skill(product-design)', 'design produit / flow utilisateur')
  }

  // Design / UI execution — broad semantic net
  if (/design|ui|ux|page|layout|composant|component|landing|hero|section|card|button|form|nav|sidebar|couleur|color|font|typo|icon|style|theme|dark|light|responsive|mobile|visual|interface|écran|screen|figma|sketch/.test(msg)) {
    add('design', 'Skill(product-design) + Skill(impeccable) + Skill(taste-skill)', 'tâche UI/design détectée')
  }

  // Animation / motion
  if (/animation|motion|micro-?interaction|transition|easing|framer|spring|hover|press|feel(s)? (good|right|off|weird)|smooth|polish/.test(msg)) {
    add('animation', 'Skill(emil-design-eng) + Skill(review-animations)', 'motion/animation détecté')
  }

  // Code review / quality
  if (/review|audit|qualit|refactor|clean|améliore|optimis|simplif|revu|inspect|analys/.test(msg) && !/design/.test(msg)) {
    add('review', 'Skill(code-review)', 'revue/optimisation code')
  }

  // Testing
  if (/test|tdd|spec|coverage|jest|vitest|playwright|cypress|unit|intégration|e2e/.test(msg)) {
    add('tests', 'Skill(tdd-workflow)', 'tâche test détectée')
  }

  // Debug / fix
  if (/debug|bug|crash|error|erreur|broken|fix|cass|plante|fail|issue|probl[eè]me|ne fonctionne|marche pas/.test(msg)) {
    add('debug', 'Skill(systematic-debugging)', 'débogage détecté')
  }

  // Security
  if (/s[eé]curit|auth|token|password|mot de passe|api.?key|secret|jwt|oauth|permission|inject|xss|csrf|vuln/.test(msg)) {
    add('security', 'Skill(security)', 'contexte sécurité détecté')
  }

  // Planning / architecture
  if (/plan|architectur|feature|fonctionnalit|roadmap|comment impl|comment faire|comment cr[eé]er|structur|syst[eè]me|conception|design pattern/.test(msg)) {
    add('plan', 'Skill(writing-plans) + Skill(executing-plans)', 'conception/planification')
  }

  // Verification / deploy
  if (/v[eé]rif|check|qa|deploy|ci|cd|build|lint|test.*avant|avant.*push|pr[eê]t|ready/.test(msg)) {
    add('verify', 'Skill(verify)', 'vérification/déploiement')
  }

  // Agentic practice — before commit/push, clean work
  if (/avant.*(push|commit)|bonne pratique|proprement|production-?ready|best practice/.test(msg)) {
    add('agentic', 'Skill(agentic-practice)', 'discipline agentic')
  }

  // Prose / writing
  if (/blog|article|r[eé]dige|r[eé][eé]cris|réécrire|copie|texte|README|documentation|newsletter|email|slop|sans ia|nettoie.*texte/.test(msg)) {
    add('prose', 'Skill(prose-clean)', 'rédaction / nettoyage prose')
  }

  // Marketing / growth
  if (/campagne|landing|cro|conversion|funnel|ad copy|copywriting|growth|a\/b|value prop|pitch|vend|seo/.test(msg)) {
    add('marketing', 'Skill(marketing-growth)', 'marketing / conversion')
  }

  // Research
  if (/recherche|benchmark|compare|comparer|tendance|trend|que disent|avis sur|reviews? de|meilleur.*que|state of/.test(msg)) {
    add('research', 'Skill(web-research)', 'recherche multi-source')
  }

  // Multi-agent / orchestration
  if (/orchestr|workflow complexe|d[eé]compose|multi-?agent|fais x puis|audit exhaustif|comprehensive|à grande échelle|migration/.test(msg)) {
    add('multiagent', 'Skill(context-engineering)', 'orchestration multi-agent')
  }

  // Nova agency services
  if (/spot|pub\b|teaser|reels|campagne (meta|google)|site client|vitrine|seo local|référencement|google business|agent ia|client\b/.test(msg)) {
    add('nova', 'Skill(nova-agency)', 'livrable agence Nova')
  }

  // Video / ads / motion production
  if (/vid[eé]o|motion.?design|ads?\b|teaser|trailer|spot|pika|hyperframes|remotion|render|composition|explainer/.test(msg)) {
    add('video', 'Skill(video-generation)', 'vidéo/ads/motion')
  }

  // New feature (no other category matched)
  if (Object.keys(hits).length === 0 && /cr[eé]e|ajoute|impl[eé]mente|construit|fais|génère|nouveau|nouvelle|build|make|add/.test(msg)) {
    add('feature', 'Skill(brainstorming) → Skill(writing-plans)', 'nouvelle fonctionnalité — brainstorm + plan')
  }

  // Order by priority
  return Object.values(hits).sort((a, b) => {
    const ia = PRIORITY.indexOf(a.key), ib = PRIORITY.indexOf(b.key)
    return (ia < 0 ? 99 : ia) - (ib < 0 ? 99 : ib)
  })
}

function extractLearningsSnippet(md) {
  // Extract last 15 lines of learnings, skip headers
  const lines = md.split('\n')
    .filter(l => l.trim() && !l.startsWith('#'))
    .slice(-15)
  return lines.join('\n')
}
