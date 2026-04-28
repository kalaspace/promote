# Skill Grammar — la grammaire commune des bons skills Claude Code

> Source : Chapitre 34 du livre "Dinguerie Claude Code : les skills" (François Neumann).
> Fonction dans ce projet : **BEFORE-MANDATORY de Phases 1, 2, 4**. Toute création ou édition d'un SKILL.md dans `promote/.claude/skills/` doit avoir intégré cette grammaire. Sert aussi de référence pour le pattern compliance check.

---

## Méthode de la synthèse

Cette grammaire est issue de la lecture verbatim de **14 SKILL.md locaux** (sous-skills de book-genesis, ~5800 lignes cumulées) + **4 skills externes** lus dans leur intégralité (`frontend-design` Anthropic, sub-skills `brainstorming` et `writing-plans` de Superpowers, `andrej-karpathy-skills` de Forrest Chang). 18 SKILL.md, lus ligne par ligne.

Les patterns ne sont pas inventés. Ils sont **intersectés** : un pattern ne figure dans la liste que s'il apparaît dans au moins 4 des 18 SKILL.md. Les anti-patterns idem.

Les citations sont brutes. Pas reformulées.

---

## Partie 1 — Les 15 patterns invariants

Présents dans la quasi-totalité des skills examinés. Pas tous présents en même temps — mais leur **absence systématique** dans un skill est un signal de problème.

### Pattern 1 — Pipeline Position : le skill sait où il s'insère

Un bon skill ne s'auto-décrit pas comme isolé. Il se décrit positionné dans un pipeline.

book-genesis exemple extrême : 17 phases explicites, gates entre chaque, position de chaque sous-skill dans la chaîne globale.

Citation verbatim :
> *PHASE 3.1: DIALOGUE POLISH -> /dialogue-polish (per chapter, after prose-craft)*

Le *after prose-craft* est central. Il indique que dialogue-polish présuppose l'existence de prose. Il ne fonctionne pas avant.

Pattern retrouvé dans voice-fingerprint :
> *Runs AFTER: narrative-foundation (which produces foundation.md...). Runs BEFORE: Any writing begins (prose-craft, chaos-engine, dialogue-polish, hook-craft).*

Et dans entity-tracker :
> *BUILD Mode (Phase 2.7) — Runs AFTER: narrative-foundation... and at least one chapter has been written. Runs BEFORE: continuity-guardian's first batch audit.*

Et chez Superpowers `brainstorming` :
> *Do NOT invoke any other skill. writing-plans is the next step.*

**Test** : ouvre un skill. Cherche *"after"*, *"before"*, *"once"*, *"once you have"*. Si tu ne trouves rien, le skill est probablement isolé conceptuellement, et probablement plus faible.

### Pattern 2 — What you are NOT : la déclaration négative

Les meilleurs SKILL.md déclarent explicitement ce que le skill **n'est pas**.

Citation verbatim de book-genesis :
> *You are the orchestrator of a professional book creation pipeline... You NEVER write prose, dialogue, or narrative content yourself — that is the Writer's job.*

La déclaration *NEVER write prose* est aussi importante que la déclaration de ce que le skill fait. Elle empêche la dérive de scope.

entity-tracker pousse à la liste explicite. Le SKILL.md a deux sections symétriques : *WHAT YOU ARE* et *WHAT YOU ARE NOT*. La seconde est plus longue :
> *You are NOT an auditor — that is continuity-guardian's job. You are NOT a writer — that is prose-craft's job. You are NOT a conflict resolver — you flag, you never fix. You are NOT a quality evaluator — no scores, no opinions, no recommendations. You are NOT a chapter editor — you never modify manuscript files.*

quality-gate : *"You NEVER write prose. You NEVER evaluate prose. You ORCHESTRATE the evaluation-revision cycle."*

chaos-engine va jusqu'à formuler son rôle entièrement par négation :
> *Your job is to make 5-8 surgical disruptions that push it from 'competent' toward 'unforgettable.' You are NOT rewriting the chapter. You are breaking its shell so the life inside can move.*

Pattern partout. Frontend Design : *not Inter, not Roboto, not Arial*. Superpowers : *do NOT invoke any implementation skill*. claude-legal-skill : *not a replacement for attorney review*.

**Test** : cherche *"NEVER"*, *"NOT"*, *"do not"*, *"never"*. Si tu n'en trouves pas, le skill est trop *positif*, probablement insuffisamment cadré.

### Pattern 3 — Frontmatter trigger / non-trigger

Les bons SKILL.md ont un frontmatter YAML qui déclare **quand le skill s'active** et **quand il ne s'active pas**.

Frontmatter typique :
```yaml
---
name: skill-name
description: Activates when [specific trigger]. Does not activate for [non-trigger].
capabilities: [filesystem-read, filesystem-write]
---
```

Le *Does not activate for* est central. Évite que Claude invoque le skill par sur-zèle dans des cas non pertinents.

Le frontmatter d'`alex-hormozi-perspective` dédie un paragraphe complet aux non-triggers :
> *Do NOT trigger for: capital-intensive business questions (manufacturing, biotech, hard tech, regulated industries), public-company strategy, pure tech/SaaS at scale, neutral biographical questions about Hormozi or Acquisition.com (answer those as a normal assistant with sources).*

Cinq exclusions explicites. Sans elles, le skill se déclencherait sur n'importe quelle question business.

### Pattern 4 — BEFORE-MANDATORY : pré-conditions explicites

Les meilleurs skills exigent que des conditions soient remplies **avant** de s'exécuter.

book-genesis pour passer Phase 1 → 1.5 :
> *Market research report exists with comp titles. Genre conventions documented. Word count target defined. Engagement type identified (primary + secondary minimum). User explicitly approves direction.*

quality-gate démarre par six BEFORE-MANDATORY :
> *1. Read PROJECT_STATE.yaml. 2. Read foundation.md. 3. Read outline.md. 4. Read voice-bank/README.md. 5. Read research/bestseller-dna.md if it exists. 6. Read any prior quality gate logs.*

chaos-engine *cinq* lectures mandatoires : *Read the chapter completely. Read foundation.md. Read outline.md. Read the voice bank, especially the voice-breaking samples. Read the Writer's self-report.*

prose-craft impose un rituel pré-écriture : la **freewrite to /dev/null** — 200 à 300 mots écrits dans la voix du personnage avant de commencer le chapitre, qui ne sont pas sauvegardés :
> *This freewrite goes to /dev/null — it is not saved. Its purpose is to BECOME the character before writing their story.*

**Test** : y a-t-il des *checks* explicites avant l'exécution ? Y a-t-il des *fail-stops* si les checks échouent ?

### Pattern 5 — Genre-adjusted thresholds

Les bons skills ne posent pas de seuils universels. Ils **calibrent** les seuils au context.

book-genesis sur l'anti-AI scan :
> *Genre-adjusted anti-AI targets. Human bestsellers score 0-13 on the scan. Target is genre-appropriate, not zero. Literary: 0-3. Memoir: 0-4. Commercial: 0-8. Prescriptive NF: 0-12.*

chaos-engine table calibrée :
```
Literary Fiction:    Max 3 instances, 0.5/1K words density
Memoir:              Max 4 instances, 0.6/1K words density
Commercial Fiction:  Max 6 instances, 0.8/1K words density
Prescriptive NF:     Max 8 instances, 1.0/1K words density
```

Frontend Design calibre par direction conceptuelle. Mastering-engineer calibre par plateforme cible.

**Test** : le skill a-t-il des paramètres ajustables selon le contexte ?

### Pattern 6 — Strengths to PRESERVE

Discipline rare : **préserver les forces**, pas seulement corriger les faiblesses.

book-genesis dans le dispatch de book-editor :
> *Fix without degrading identified strengths: [list top 3 strengths].*

book-editor : *"Surgical revision specialist. Rewrites specific passages based on Evaluator feedback without degrading existing strengths."* Le mot **surgical** porte la responsabilité opérationnelle.

Pattern : tout skill qui modifie un artefact existant devrait connaître ce qui marche déjà avant de toucher.

### Pattern 7 — Max iterations + escalation

Les bons skills posent des **limites** sur le nombre d'itérations avant escalade.

book-genesis : *"Max 3 iterations per chapter. If floor didn't improve after 3 iterations -> escalate to orchestrator as structural issue."*

quality-gate dans YAML : *"max_iterations: 3, max_structural_loopbacks: 1"*. Documente l'escalade : *"iteration < max? YES -> loop back. NO -> ESCALATE (to orchestrator)."*

Nuwa : *"Phase 2 → 4 maximum loop 2 times. After 2 rounds, if items still fail, mark them in honest boundaries and ship the current best version rather than infinite polish."*

C'est l'antithèse du LLM serviable qui itère sans fin pour faire plaisir.

### Pattern 8 — Test signature

Un test reproductible, simple, qui dit **oui ou non, le skill a marché**.

Exemples :
- **Midnight Test** (book-genesis) : si on lit le premier paragraphe à minuit, est-ce qu'on a envie de lire le second ?
- **Cover-the-Name Test** (voice-fingerprint) : si on cache le nom du speaker, est-ce qu'on devine qui parle ?
- **Tomorrow Test** (book-genesis) : combien d'ancres concrètes le lecteur retient-il le lendemain ? Compté et tracké.
- **XBOW score** (Shannon) : 100/104 exploits réussis, hint-free, source-aware.
- **Coffee mug test** (prose-craft) : tu lis une page en buvant ton café ; au moment où tu poses ta tasse, qu'est-ce que tu retires ?

hook-craft test brut :
> *A book with perfect prose and weak hooks is a book that gets abandoned at Chapter 3. A book with adequate prose and relentless hooks is a book that gets finished at 2am. You build the 2am book.*

Pas une métrique numérique. Une scène concrète : 2h du matin, le lecteur n'a pas posé le livre.

**Test** : si tu ne peux pas formuler un test simple qui distingue *le skill a marché* de *le skill a produit du contenu*, ton skill est trop subjectif.

### Pattern 9 — Numbered N moves

Les bons skills donnent des **moves numérotés** explicites au LLM.

book-genesis : *"Apply >=5 of 8 disruption operations."* — Huit opérations énumérées. Au moins cinq d'entre elles. Pas *"sois créatif"*.

Pattern partout : 41 risk categories CUAD, 50+ vulnerabilities classes Shannon, 4 principes Karpathy, 8 swarms Loki Mode, 9 quality gates, 8 dimensions Nuwa, 6 hook types hook-craft.

prose-craft énumère 8 types structurels obligatoires : Chronological / Reverse chronological / Fragmented / Essayistic / Spiral / Parallel / Epistolary / Stream of consciousness. Et impose : *"If the previous chapter used structure X, you CANNOT use structure X again."*

Le LLM exécute **mieux** avec une liste finie. Ouverte (*"applique des techniques de bonne prose"*) = contenu moyen. Fermée (*"applique au moins 5 de ces 8"*) = contenu calibré.

### Pattern 10 — YAML state file

Les skills qui durent dans le temps ont une **source de vérité** en YAML.

book-genesis : `STATE.yaml` + `ENTITY_STATE.yaml`. manuscript-manager *est* le skill qui maintient la source : *"You are the project's persistent memory system. Without you, every session starts from zero. With you, 50 sessions build a coherent book. You don't write — you TRACK."*

Philosophie : *"A manuscript is an engineering project with dozens of sessions, thousands of decisions, and multiple skills operating. The only reason this works without descending into chaos is persistent state. You are that state."*

Pas besoin de vector store, pas besoin de mémoire propriétaire. Cinq fichiers Markdown ou YAML suffisent.

### Pattern 11 — Dispatch templates

Les skills d'orchestration ont des **dispatch templates** explicites pour chaque sous-skill.

book-genesis template par phase :
```
Next step: invoke /[skill-command]
Task: [Specific task].
Project dir: [path]
Read: [relevant state files]
Constraints: [word count, voice bank reference, what NOT to change]
Deliverables: [expected outputs]
```

Cinq sections, toujours les mêmes, pour chaque sous-skill.

book-auto codifie le pattern à un niveau supérieur : *"One-command book generation. Give it an idea, get a publish-ready book."* Et son corps liste les seize étapes que l'orchestrateur dispatche, en numérotation séquentielle, avec trois **checkpoints humains** explicites.

Si tu écris un skill qui en orchestre d'autres, copie ce pattern.

### Pattern 12 — Output structuré

Les meilleurs skills ne produisent pas du Markdown freeform. Ils produisent un **artefact structuré** prévisible.

Grill Me produit l'arbre de décision en sections numérotées. claude-legal-skill produit un Word avec tracked changes. AgriciDaniel SEO produit un PDF formaté. K-Dense produit du Markdown imbriqué avec sections fixes.

voice-fingerprint produit **exactement** `voice-dna.md` — *"the single source of truth for how every character sounds, thinks, and breaks."*

L'output structuré permet la **composition**. La sortie de A devient l'entrée de B.

L'output freeform tue la composition.

**Règle** : ton skill produit un artefact qui suit une structure documentée.

### Pattern 13 — V-tag versioning

Les skills sérieux versionnent.

book-genesis a un V4 explicite, avec un *what's new in V4*. Comp tables avec V3.1 (Intrasystem Bias Protocol), V3.2 (Floor doesn't predict sales), V3.7 (Genesis Score). prose-craft V3.7. voice-fingerprint V3.7.

Superpowers V4 documenté dans un blog post, V5 fin mars 2026. Chaque release datée, taguée, accompagnée d'un changelog public.

Inclure `version: X.Y` dans le frontmatter et un changelog en bas du SKILL.md = signal de sérieux. Et utile : dans 6 mois, tu sais ce que tu as cassé entre V1.2 et V1.3.

### Pattern 14 — Voix d'auteur impérative

Les meilleurs SKILL.md sont écrits à la **deuxième personne impérative**. *"You are X. You do Y. You never do Z."*

Citation book-genesis : *"You are the orchestrator of a professional book creation pipeline."* Pas *"This skill is a..."* (descriptive, faible). *"You are..."* (prescriptive, impérative).

prose-craft pousse à la formule programmatique : *"You are a writer. Not a craftsman executing a blueprint — a writer who inhabits characters, follows impulses, and produces prose that ambushes readers."*

chaos-engine assume une métaphore : *"You are the disruptor... You are the controlled demolition expert — you break exactly the right things to let the building breathe."*

manuscript-manager : *"You are the project's persistent memory system."*

hook-craft : *"You are the gatekeeper of momentum."* Cinq mots. Tout le rôle.

`alex-hormozi-perspective` : *"Use 'I' — never 'Hormozi would say…' or 'Alex might think…'"*. Le skill **interdit** la troisième personne. La voix impérative passe en première personne quand le skill incarne quelqu'un.

Cette voix transforme le LLM. *"You are X"* → adopte le rôle. *"This is a skill that does X"* → continue à être lui-même.

**Règle** : écris ton SKILL.md à la deuxième personne impérative.

### Pattern 15 — Anti-patterns explicites

Les meilleurs skills disent **quoi ne pas faire**, en détail.

Frontend Design interdit Inter, Roboto, Arial, dégradés violet. Impeccable interdit drop-shadows par défaut. Vossify liste les phrasings qui activent la défensive.

mechanical-preprocess explicite *pourquoi* il existe : *"AI agents are bad at processing entire manuscripts for mechanical fixes. Context windows overflow, attention drifts, and the agent 'forgets' the rules by chapter 15."* Le skill se positionne comme contre-mesure à un anti-pattern documenté du LLM lui-même.

book-genesis encode son **Pattern #11 (Explanatory Extension)** comme l'anti-pattern numéro un : *"the single most AI-identifiable fingerprint."*

`alex-hormozi-perspective` interdit même son propre signature move utilisé deux fois : *"the diagnosis flip ('you don't have X, you have Y') is my single most-mimicked move. It loses force when used twice in one answer or three answers in a row... one signature move per answer is the ceiling. Anything more is parody."*

Frontend Design verbatim :
> *NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.*

C'est dur. C'est désiré.

---

## Partie 2 — Les 5 sous-écoles stylistiques

### Sous-école A — Kitchen-sink orchestrator

**Exemples** : book-genesis, Loki Mode, Claude-Code-Game-Studios, the-startup, Superpowers.

**Posture** : un domaine entier, encodé en hiérarchie d'agents avec gates, états, pipelines.

**Caractéristiques** :
- Plusieurs sous-skills (10 à 50+).
- Hiérarchie explicite (orchestrator → leads → specialists).
- States persistés en YAML/Markdown.
- Quality gates entre phases.
- SKILL.md long (1000+ lignes).

**Voix typique** : impérative et systémique. *"You are the orchestrator..."* (book-genesis). *"You are the project's persistent memory system."* (manuscript-manager).

**Quand l'écrire** : tu maîtrises un domaine pro complet, tu as identifié 10-30 sous-tâches récurrentes, et le pipeline de bout-en-bout a une vraie valeur.

**Quand ne pas l'écrire** : pour un cas d'usage ponctuel, un workflow simple, ou un skill qui couvre un seul moment-décision.

### Sous-école B — Lightweight orchestrator

**Exemples** : marketing skills de Corey Haines, AgriciDaniel claude-seo, Marie-Claire Dean, `book-auto`.

**Posture** : plusieurs sous-skills cohérents, partageant un foundation commun, mais sans hiérarchie d'agents lourde.

**Caractéristiques** :
- 10-30 sub-skills.
- Un skill foundation que les autres consomment.
- Pas de quality gates strictes — l'utilisateur décide quand passer à l'étape suivante. Sauf checkpoints humains explicites comme dans book-auto (*"three human checkpoints"*).
- SKILL.md modéré (200-500 lignes par sub-skill).

**Voix typique** : déclarative simple. *"Give it an idea. Get a book. That's it."* Pas de paragraphes interminables. Le skill se vend en deux phrases.

**Quand l'écrire** : suite de tâches reliées thématiquement, mais l'utilisateur les invoque selon ses besoins, pas dans un ordre fixe.

### Sous-école C — Scoped surgeon

**Exemples** : chaos-engine, hook-craft, voice-fingerprint, dialogue-polish, Grill Me, x-impact-checker, salary-negotiation.

**Posture** : un seul skill qui fait une seule chose, très bien, avec des contraintes précises.

**Caractéristiques** :
- Un seul skill, une seule responsabilité.
- Scope étroit explicite.
- Test signature reproductible.
- SKILL.md court (100-300 lignes).
- Output structuré minimal.

**Voix typique** : métaphore d'autorité technique. *"You are the disruptor."* (chaos-engine). *"You are the gatekeeper of momentum."* (hook-craft). *"You are a voice architect."* (voice-fingerprint).

Pattern : une métaphore opérationnelle qui définit le rôle en cinq mots, suivie d'une justification d'une phrase.

Verbatim hook-craft :
> *You are the gatekeeper of momentum. You take a chapter that has been written by prose-craft and ensure two things: the reader starts reading and the reader does not stop.*

Cinq mots de définition. Une phrase d'explication. Le rôle est posé.

**Quand l'écrire** : moment-décision précis qui mérite un skill dédié. Test signature en une phrase.

**Quand ne pas l'écrire** : si tu te dis *"je vais peut-être ajouter d'autres choses plus tard"*. Le scoped surgeon doit rester scoped.

### Sous-école D — Persona-incarnée

**Exemples** : nuwa-skill personas, andrej-karpathy-skills, slavingia/skills, `alex-hormozi-perspective`.

**Posture** : encoder le cerveau d'une personne ou d'un archétype. L'utilisateur invoque la persona, pas un outil.

**Caractéristiques** :
- Voix d'auteur très marquée — souvent en première personne.
- Frameworks mentaux + heuristiques + angles morts.
- Ton consistent (parfois cassant, parfois chaleureux, mais jamais neutre).
- Souvent court (200-400 lignes).

**Voix typique** : première personne, cadence imitée. `alex-hormozi-perspective` ouvre sur l'épigraphe : *"Volume negates luck. Volume × time = skill. The pain is the pitch. Strategy is easy. Execution is hard."* Phrases courtes. Syntaxe parallèle. Ton calque.

Règle de l'humilité publique dans `alex-hormozi-perspective` :
> *Limits live in my private map, not on the mic. Each mental model has a documented limit (in this file). I use them internally to calibrate my answer. I do NOT volunteer them in-character unless the user explicitly asks where the model breaks. My voice is decree, not hedge — caveats break the cadence.*

Le skill encode une **posture publique** tout en gardant les limites en **private map**. Ingénierie de voix qui distingue l'incarnation de l'imitation plate.

**Quand l'écrire** : tu encodes une expertise humaine spécifique. L'utilisateur veut consulter X, pas faire X.

### Sous-école E — Bash-first / non-AI

**Exemples** : mechanical-preprocess, planning-with-files, Loooom.

**Posture** : le LLM n'est pas le bon outil pour ce job. Du grep, du sed, du shell, du filesystem, suffisent.

**Caractéristiques** :
- Pas (ou peu) d'invocation LLM.
- Beaucoup de bash, awk, grep, sed.
- Le LLM est utilisé seulement pour interpréter ou composer.
- SKILL.md surtout fait de protocoles textuels d'utilisation d'outils.

mechanical-preprocess :
> *AI agents are bad at processing entire manuscripts for mechanical fixes. Context windows overflow, attention drifts, and the agent 'forgets' the rules by chapter 15. This skill solves that by splitting the work: Bash handles the 80% — pattern matching, counting, safe replacements. AI handles the 20% — judgment calls on ambiguous cases.*

Reconnaissance honnête des limites du LLM. Solution mécanique. Pas de gloire. Juste l'outil qui marche.

**Quand l'écrire** : job qu'un grep fait mieux qu'un LLM. Comptage, filtrage, transformation déterministe.

---

## Partie 3 — Le cadre à 8 dimensions

Quand tu lis ou conçois un skill, analyse-le sur 8 dimensions. Chaque dimension est indépendante. Le score d'ensemble est le **minimum** (le maillon faible), pas la moyenne.

| # | Dimension | Question test |
|---|---|---|
| 1 | **Contrat d'activation** | Un nouvel utilisateur lit la première page du SKILL.md. Sait-il en 30 secondes *quand* l'invoquer ? |
| 2 | **Déclaration d'identité** | Si tu remplaçais le SKILL.md par un screenshot d'une seule phrase, l'utilisateur saurait-il toujours quoi en faire ? |
| 3 | **Pré-conditions** | Si l'utilisateur invoque le skill sans rien préparer, qu'est-ce qu'il se passe ? Le skill explique ce qu'il faut préparer = bonne. Le skill exécute en mode dégradé silencieusement = mauvaise. |
| 4 | **Cœur opérationnel** | Peux-tu lister, en bullets, les 5 premières actions que le skill exécute ? |
| 5 | **Frontières** | Le SKILL.md mentionne-t-il quand le skill échoue, et que faire dans ce cas ? |
| 6 | **Test signature** | Peux-tu, en 5 minutes, vérifier que le skill a vraiment marché, ou tu te fies à l'apparence ? |
| 7 | **Output structuré** | Un autre skill (ou un script bash) peut-il consommer la sortie sans devoir parser du Markdown freeform ? |
| 8 | **Voix et autorité** | La voix du SKILL.md est-elle reconnaissable comme celle d'un expert, ou neutre comme un wikipedia ? |

---

## Partie 4 — Sous-encadré : Tomorrow / Midnight / Coffee Mug Tests

Trois tests signature simples, applicables à beaucoup de domaines :

- **Tomorrow Test** (de book-genesis) : combien d'images ou citations concrètes l'utilisateur retiendra-t-il *demain* après avoir invoqué le skill ? Pas le score immédiat. Le compte d'objets concrets *résiduels*. Si zéro, le skill produit du déchet propre.
- **Midnight Test** : si tu lis la première phrase de la sortie à minuit après une journée chargée, est-ce qu'elle te donne envie de lire la deuxième ? Test d'attention.
- **Coffee Mug Test** : tu lis la sortie en buvant ton café du matin. Au moment où tu poses ta tasse, qu'est-ce que tu **retires** ? Si c'est *"j'ai bien aimé mais j'ai oublié"*, le skill n'a pas livré.

Proxies de la valeur retenue. Délibérément informels. Marchent.

---

## Partie 5 — Le Pattern #11 (Explanatory Extension)

book-genesis identifie le **Pattern #11** comme *"the single most AI-identifiable fingerprint."* C'est l'extension explicative auto-justificative.

Forme typique :
> *X is the kind of Y that Z.*
> *Not because A, but because B.*
> *X happened, which is why we can now say that Y.*

Le LLM, quand il écrit, a tendance à **expliquer ce qu'il vient de dire**. Il ajoute une extension qui justifie ou clarifie la précédente. Cette extension :
- Est techniquement correcte.
- N'apporte aucune information neuve.
- Trahit le LLM (un humain n'écrit pas comme ça constamment).

chaos-engine dédie le statut de *HIGHEST PRIORITY* à cet anti-pattern :
> *Find every simile or metaphor that EXPLAINS itself (the analytical simile — the pipeline's signature fingerprint). V3 benchmark showed this pattern in EVERY chapter of a 14-chapter manuscript. This is the #1 AI tell.*

Si ton skill produit des outputs narratifs (briefs, rapports, lettres), inscris dans le SKILL.md : *"évite la simile auto-explicative étendue, écris la simile RAW."*

---

## Partie 6 — Les 7 questions à te poser avant d'écrire un SKILL.md

| # | Question | Si tu n'as pas la réponse |
|---|---|---|
| Q1 | Quel **moment-décision spécifique** je couvre ? | Si ta réponse contient *"globalement"*, *"toutes les fois où"*, *"en général"*, tu es trop large. Resserre. |
| Q2 | Qui invoque ce skill, **précisément** ? | Pas *"les devs"*. *"Le PM tech-lead d'une boîte SaaS B2B 20-50 employés qui doit pricer un nouveau plan."* |
| Q3 | Qu'est-ce qui **doit exister avant** l'invocation ? | Si la réponse est *"rien"*, ton skill devra demander des inputs initiaux. Liste les questions à poser. C'est ton premier move numéroté (Pattern 9). |
| Q4 | Quelles sont les **5 premières actions** que le skill exécute ? | Cinq, pas plus. Si tu ne peux pas les lister, tu n'as pas encore le skill clair en tête. |
| Q5 | Quel est mon **test signature** ? | Un compte. Un seuil. Un binaire oui/non. Un benchmark. Un Tomorrow Test. Si ta réponse est *"je relis et je vois si c'est bien"*, ton test signature n'existe pas encore. |
| Q6 | Quelle est la **forme de l'output** ? | Markdown structuré ? Word ? PDF ? JSON ? Si la réponse est *"un texte qui est utile"*, tu es trop vague. |
| Q7 | Qu'est-ce que mon skill **n'est PAS** ? | Trois choses qu'il refuse. Trois moments où il échoue gracieusement en disant *"ce n'est pas mon job"*. Question la plus négligée. Sans réponse, ton skill dérive de scope. |

---

## Partie 7 — Squelette d'un SKILL.md minimal

Structure recommandée. Une cinquantaine de lignes. Avec ça, les 8 dimensions sont couvertes et au moins 10 des 15 patterns intégrés.

```markdown
---
name: my-skill
description: Activates when [precise trigger]. Does not activate for [non-trigger].
capabilities: [filesystem-read, filesystem-write]
version: 0.1.0
---

# my-skill

You are [role identity, second person impérative].

You [main action]. You NEVER [explicit boundaries].

## Pre-conditions

Before invoking this skill, the user must have:

- [Condition 1]
- [Condition 2]
- [Condition 3]

If any of these conditions is not met, output a clear message explaining what is missing, and do NOT proceed.

## Operational core

When invoked, execute the following moves in order:

1. [Move 1, with specific action]
2. [Move 2]
3. [Move 3]
4. [Move 4]
5. [Move 5]

For each move, [validation step].

## Anti-patterns to AVOID

- [Anti-pattern 1, e.g., generic phrasings]
- [Anti-pattern 2]
- [Anti-pattern 3]

## Output structure

The output MUST follow this structure:

\`\`\`markdown
# [Title]

## Section 1
[content with constraints]

## Section 2
[content with constraints]
\`\`\`

## Test signature

The skill has succeeded if:

- [Measurable criterion 1]
- [Measurable criterion 2]

If criteria are not met, [escalation procedure].

## Frontiers

This skill does NOT:

- [Limit 1]
- [Limit 2]
- [Limit 3]

For these cases, recommend [alternative skill or human action].

## Changelog

- 0.1.0 — Initial release.
```

---

## Pattern compliance checklist (à appliquer à chaque skill créé/édité dans ce projet)

- [ ] Pattern 1 — Pipeline Position : le SKILL.md indique explicitement *after X* / *before Y*.
- [ ] Pattern 2 — NEVER : au moins 3 déclarations négatives explicites.
- [ ] Pattern 3 — Frontmatter trigger ET non-trigger.
- [ ] Pattern 4 — BEFORE-MANDATORY : conditions vérifiables avant exécution.
- [ ] Pattern 7 — Max iterations + escalation : limite numérique sur les boucles, fail-stop documenté.
- [ ] Pattern 8 — Test signature : un test reproductible et mesurable est nommé.
- [ ] Pattern 9 — Numbered N moves : les actions du cœur opérationnel sont énumérées (5+).
- [ ] Pattern 10 — YAML state file (si stateful).
- [ ] Pattern 11 — Dispatch templates explicites (si orchestrateur).
- [ ] Pattern 12 — Output structuré dans une forme documentée.
- [ ] Pattern 13 — Frontmatter `version: X.Y` + changelog.
- [ ] Pattern 14 — Voix impérative à la 2e personne (*"You are X. You do Y. You NEVER Z."*).
- [ ] Pattern 15 — Anti-patterns explicites listés.
- [ ] 8 dimensions auditées : contrat d'activation / identité / pré-conditions / cœur opérationnel / frontières / test signature / output / voix.

Tout skill qui manque plus de 3 patterns sur 14 doit être **rejeté et réécrit**.
