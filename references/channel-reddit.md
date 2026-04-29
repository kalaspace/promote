# Reddit (organique)

> **Channel scope** : ce framework couvre Reddit **organique** — sélection de subreddits, posting, AMA, account aging, anti-shadowban. **Ne couvre PAS** : Reddit Ads (→ paid framework dédié) ni l'intégration Reddit Pixel pour le retargeting visiteur (→ `promote-robinson-outbound`).
> **Why framework, not operator** : pas de figure dominante 2026 sur Reddit organic. Le game est tactique, fragmenté **par subreddit**, et chaque communauté a ses normes propres. Aucun "Reddit guru" récent n'a produit une doctrine généralisable — le savoir vit dans les wikis de subreddits, pas chez un opérateur incarnable.
> **Used by** : `promote-channel-strategist` quand Reddit est retenu dans le mix (typique pour B2C niche, dev tools, gaming, finance, fitness, hobby-driven products).

## Quand consulter ce framework

**Fits** :
- ICP est sur Reddit (vérifiable : `site:reddit.com [ton ICP keyword]` retourne ≥3 subreddits actifs avec >10k membres).
- Produit a une niche claire avec un ou plusieurs subreddits dédiés (r/selfhosted, r/devops, r/personalfinance, r/keto, etc.).
- Budget cash limité, mais bandwidth humain disponible (Reddit récompense le temps, pas l'argent).
- Founder ou team prête à **participer en tant qu'humain** sur 6+ mois (pas de "campagne" 4 semaines).

**Anti-fits** :
- ICP enterprise C-level (CEO Fortune 500 ne lit pas r/startups).
- Produit nécessitant trust/credentials lourds dès la première impression (cabinet d'avocats, banque privée).
- Team qui ne peut pas commit du temps human pour participation authentique → tu vas shill, te faire ban, gravely.
- Pays où Reddit a une pénétration faible (FR/DE/IT — Reddit y existe mais reste US/UK/CA-dominant).

## Tactiques 2026

### 1. Subreddit selection avec CQS (Community Quality Score)

Avant de poster, score chaque subreddit candidat sur 5 critères (1-5 chacun, total /25) :

- **Activity ratio** : posts/jour ÷ subscribers × 1000. Sweet spot : 0.5–3. Trop bas = mort. Trop haut = noyé.
- **Comment-to-post ratio** : moyenne sur les 20 derniers posts. >5 = communauté engagée. <2 = lurker-heavy, faible reach.
- **Mod tolerance to self-promo** : lis le wiki + sticky posts. Cherche "self-promotion", "9:1 rule", "no advertising". Note la sévérité.
- **Niche fit** : ton ICP est-il là ? Use Reddit search + GummySearch pour vérifier.
- **Founder presence accepted** : certains subreddits autorisent les founders à se présenter (r/SaaS, r/SideProject) ; d'autres bannent à vue (r/programming).

CQS ≥18/25 = subreddit prioritaire. Entre 12 et 17 = secondaire. <12 = skip.

### 2. Value-first posting (ratio 9:1 give:ask)

La règle Reddit officielle (codifiée par /u/krispykrackers en 2014, toujours vivante 2026) : **pour chaque 1 self-promo post/comment, fais 9 contributions community sans aucun lien vers ton produit**.

- Compte les comments, pas seulement les posts. 9 comments substantiels (>2 lignes, valeur réelle) = droit à 1 self-promo.
- "Substantiel" = répondre à une vraie question, partager une expertise, ne PAS être "great post!".
- Track le ratio dans un Notion/sheet. Sans tracking, tu shill sans le savoir.

### 3. AMA mechanics

AMAs sont sous-utilisés en 2026. Le format marche encore mais nécessite un rituel :

- **Pré-requis** : compte aged ≥6 mois, ≥1000 karma, contributions vérifiables dans 3+ subreddits différents.
- **Title** : "I'm [name], I [specific credible thing]. AMA." Pas de marketing jargon.
- **Proof** : photo verified ou tweet/site avec timestamp. Mods rejettent sans proof.
- **Pré-write 5-10 réponses** aux questions évidentes (your pricing? your tech stack? your burn?). Tu réponds en live mais tu as les briques.
- **Stay 2h minimum**. Reddit pénalise les AMAs où le poster disparaît.
- **Don't promote**. L'AMA n'est PAS pour vendre. Elle plante un marqueur de présence légitime, qui infuse pendant des mois.

### 4. Account aging (>6 mois minimum)

Reddit pondère les nouveaux comptes négativement. Karma + ancienneté = trust signal.

- Crée un compte "founder" pro 6 mois avant ton premier post promo.
- Pendant ces 6 mois : commente, vote, contribue. **Ne mentionne JAMAIS ton produit**.
- Cible 1000+ comment karma + 500+ post karma avant le premier self-promo.
- Disclose ton affiliation quand pertinent ("disclosure: I built X") — la transparence aged + disclosed bat le shilling stealth.

### 5. Multi-account brand_PersonName patterns

Pour comptes officiels d'entreprise, le pattern qui marche en 2026 :

- `brand_PersonName` (ex : `linear_karri`, `vercel_lee`). Communique : c'est une vraie personne **chez** la brand, pas un community manager anonyme.
- Le compte assume des opinions personnelles, pas du corporate-speak.
- Limite : 1-2 brand_PersonName par boîte max. Au-delà = bot army perception.

### 6. Reddit Pixel + outbound integration

Reddit Pixel (visitor ID) capture les redditeurs qui visitent ton site. Combine avec `promote-robinson-outbound` :

- Pixel sur landing → match avec base outbound (LinkedIn, email enrichi).
- Les visiteurs Reddit ont haut intent niche : score-prioritise-les en outbound.
- Voir `promote-robinson-outbound` pour le détail technique du match Pixel→identity.

### 7. Anti-shadowban tactics 2026

Reddit shadow-ban silencieusement. Tu postes, ça apparaît pour toi, mais personne ne voit. Signaux :

- Crée un incognito tab non-loggé. Cherche tes posts récents. Visibles ? Non = shadowban.
- Post karma stagne malgré activité = signal.
- Évite : 3+ posts dans 24h, posts avec >2 liens externes, posts avec UTMs trackés visibles, comptes liés VPN-rotators.

## Cadence + format recommandé

- **Volume hebdomadaire** : 5-15 comments substantiels par jour, 1-2 posts par semaine max (per subreddit).
- **Formats prioritaires** : (a) longform text post (1000-2500 mots) avec valeur standalone ; (b) commentaires-réponses qui répondent vraiment ; (c) AMA tous les 6 mois si tu as une nouveauté légitime.
- **Anti-formats** : crossposts spammy, link-only posts, posts copiés d'un blog avec UTM, "I made X, what do you think?" sans context.

## Anti-patterns 2026

1. **Spray-and-pray multi-subreddit** : poster le même contenu dans 5 subreddits le même jour = ban quasi-garanti (filtre Reddit anti-crosspost).
2. **Stealth shilling** : recommander ton produit en pretendant être un user neutre. 2026, les communautés détectent en 24h via comment history.
3. **AMA "I'm a founder, AMA"** sans credentials specific. Mort à l'arrivée. Soit tu as un edge concret, soit pas d'AMA.
4. **Compte tout-neuf qui poste promo** : auto-ban filter sur la majorité des subreddits >50k members.
5. **Ignorer le wiki + rules** : chaque subreddit a ses règles. Mods bannent sur première violation, sans warning.
6. **Engineering upvotes** (vote brigading via Slack/Discord) : Reddit détecte les patterns de votes coordonnés et tank le post (parfois shadow-ban le compte).
7. **Disparaître après le post** : poster puis ne pas répondre aux comments = signal de shilling. Reste 2h+ après chaque post substantiel.

## Mesure / KPIs

- **Subreddit-level engagement** : upvote ratio (>0.85 = bonne réception), comment count, ratio comments/upvotes.
- **Karma trajectory** : track post + comment karma sur 90 jours. Plateau = sortir de la "naïveté algo" Reddit.
- **Referral traffic** (Reddit → site) : segment GA4 ou Plausible par source `reddit.com`. Sweet spot : 5-15% du traffic site pour boîtes B2C niche.
- **Pixel-captured visits** : voir `promote-robinson-outbound` pour transformation outbound.
- **Mention organic** (someone else mentions you) : KPI le plus fort. Track via Reddit search + Mention.com sur ton brand name.
- Benchmarks 2026 : un post "réussi" dans subreddit 50-200k = 100-500 upvotes, 30-100 comments, 1-3% du subscribers count en views.

## Sources

- Reddit official self-promotion guidelines : https://www.reddit.com/wiki/selfpromotion
- GummySearch (subreddit research tool) : https://gummysearch.com
- /u/krispykrackers original 9:1 codification (archived) : https://www.reddit.com/r/blog/comments/2zh7lz/
- Subreddit Stats : https://subredditstats.com
- F5Bot (Reddit mention monitoring) : https://f5bot.com

## Changelog

- 0.1.0 (2026-04-29) — Initial release.
