---
name: nova-agency
description: >-
  Coordinator for creative-agency work — ad spots, paid campaigns, client
  sites, local SEO, and AI automation. Use when a request is agency/client
  delivery rather than generic engineering. Routes to the right specialist
  behavior and the right general skill. Trigger on spot, pub, ad, campagne,
  Meta Ads, Google Ads, client site, SEO local, agent IA, teaser, or a named
  client deliverable.
---

# Nova Agency

Route agency deliverables to the right playbook, then compose with the general skills. This skill decides *which service* and *which supporting skills*, it does not duplicate them.

## Service router

| Signal | Service | Compose with |
| --- | --- | --- |
| spot, pub, teaser, reels, trailer, montage | **Video / ad production** | `Skill(video-generation)` (Pika, Hyperframes, Remotion) |
| campagne, Meta Ads, Google Ads, budget, audience, A/B | **Paid campaigns** | `Skill(marketing-growth)` |
| site client, landing, vitrine, refonte | **Web creation** | `Skill(product-design)` + `Skill(impeccable)` + `Skill(marketing-growth)` |
| SEO, Google Business, référencement, local, géo | **Local SEO** | `Skill(marketing-growth)` (SEO on-page section) + `Skill(web-research)` |
| agent IA, automatisation, workflow client | **AI automation** | `Skill(context-engineering)` |

## Delivery principles

- **Client-first language.** Deliverables are described in outcomes the client cares about (leads, bookings, reach), not internal mechanics.
- **French by default** for Nova (Belgium + France clients) unless asked otherwise.
- **Conversion over decoration.** Every asset has a job: awareness, consideration, or action. Name it.
- **Belgium + France context** for local SEO and ads targeting (NAP, geo keywords, regional platforms).

## Video / ad production

Brief → concept → script (hook / problem / solution / CTA) → storyboard → generate → export.
Formats: 16:9 YouTube, 9:16 Reels/Stories, 1:1 Feed. Respect platform specs (duration, ratio, file weight). Hand generation to `Skill(video-generation)`.

## Paid campaigns

Structure (campaign → ad set → ad), audiences, AIDA/PAS copy, budgets, KPIs, A/B tests, conversion reporting. Data-driven. Hand copy/CRO to `Skill(marketing-growth)`.

## Web creation

Architecture → wireframe → design → build → on-page SEO → deploy. Stack chosen by budget (WordPress / Webflow / Next.js). Hand the design decision to `Skill(product-design)`, execution to `Skill(impeccable)`.

## Local SEO

Google Business Profile, geo keywords, NAP citations, reviews, local ranking reports. Belgium/France focus. Verify claims and competitors with `Skill(web-research)`.

## AI automation

Configure agents, prompts, and repeatable client workflows. Cross-session memory. For anything multi-step or orchestrated, hand to `Skill(context-engineering)`.
