---
name: security
description: >-
  Revue sécurité applicative — auth, sessions, secrets, injection, contrôle
  d'accès, headers. Use when touching login, tokens, passwords, API keys,
  payments, cookies, CORS, SQL queries, or user-supplied input. Trigger on
  auth, JWT, OAuth, token, secret, mot de passe, XSS, CSRF, injection, CORS,
  permission, vulnérabilité.
---

# security — revue sécurité

## Auth & sessions

**JWT** — algo explicite (RS256 en prod, jamais `none`) · access 15 min / refresh 7 j · aucune donnée sensible dans le payload (lisible en base64) · refresh en cookie `httpOnly`, jamais `localStorage`.

**Mots de passe** — bcrypt cost ≥ 12, argon2id ou scrypt. Jamais MD5/SHA seuls. Comparaison en temps constant (`crypto.timingSafeEqual`). Minimum 12 caractères, pas de règles de composition qui affaiblissent.

**Sessions** — ID ≥ 128 bits d'entropie · régénérer l'ID après login (session fixation) · invalidation côté serveur à la déconnexion.

## Secrets

```js
// ❌ en dur, dans un log, ou dans une URL
const apiKey = "sk-prod-xxxxx"
console.log("key:", apiKey)
fetch(`/api?key=${apiKey}`)

// ✅
const apiKey = process.env.API_KEY
if (!apiKey) throw new Error("API_KEY manquante")
```

Documenter la rotation sans downtime.

## Injection

```js
db.query(`SELECT * FROM users WHERE id = ${userId}`)   // ❌
db.query("SELECT * FROM users WHERE id = $1", [userId]) // ✅

exec(`ls ${userInput}`)          // ❌
execFile('ls', [userInput])      // ✅
```

XSS — échapper tout contenu utilisateur rendu en HTML · `Content-Security-Policy` · tout `dangerouslySetInnerHTML` déclenche un audit.

## Checklist OWASP

- [ ] Injection (SQL, NoSQL, commande, LDAP)
- [ ] Auth cassée (brute force, énumération de comptes)
- [ ] Fuite de données sensibles (logs, messages d'erreur, réponses API)
- [ ] Contrôle d'accès (IDOR, élévation de privilège)
- [ ] Config (headers manquants, CORS trop ouvert)
- [ ] XSS · désérialisation non sécurisée · XXE
- [ ] Dépendances vulnérables (`npm audit`)
- [ ] Logs suffisants pour tracer un incident

## Headers

```
Content-Security-Policy: default-src 'self'
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains
Referrer-Policy: strict-origin-when-cross-origin
```
