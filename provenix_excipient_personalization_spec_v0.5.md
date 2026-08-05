# Provenix — Excipient Layer & Personalization (v0.5)

Supersedes `provenix-excipient-personalization-script.md` (Jason's original memo,
2026-08-05 draft). Every open item in that memo's Part 4 was settled with Aaron on
2026-08-05 — see the decisions log at the bottom. This document folds those decisions
back into the spec, the CLAUDE.md/AGENTS.md hard rules, and the build prompts, so it's
the version to actually build from.

Merge Part 1 into `Docs/Provenix_Product_MVP_v0.4.docx` as the v0.5 revision when you
have a moment — it's a docx/rtf pair, not something to edit by hand here. Part 2 has
already been appended to `AGENTS.md` directly. Part 3 is ready to run into Claude Code
whenever building starts.

---

# Part 1 — Spec amendment (v0.4 → v0.5)

## §9 Inactive ingredients and excipients

Product pages gain an excipient display layer. Every excipient resolves into exactly
one of three categories, and the category determines what the product is permitted to
do with it.

**9.1 — Regulatory flags.** Sourced to a named Tier-I regulatory body: FDA, EFSA,
Health Canada, or TGA. **Any single Tier-I regulator's action scores** — the score is
never gated on which of the four acted, and never gated on whether the others agree,
disagree, or stay silent. A flag with no citable regulatory action is not a regulatory
flag, whatever the underlying evidence looks like. The flag records the regulator, the
action, the jurisdiction, the effective date, and a citation URL.

Canonical example: EFSA's 2022 removal of titanium dioxide from the EU
permitted-additives list on genotoxicity grounds, with no corresponding FDA action.
EFSA's action scores on its own evidentiary merits — exactly as an FDA action would,
and exactly as an FDA warning letter already scores a facility without needing EFSA to
corroborate it. Provenix is not thereby asserting EFSA outranks FDA; it's applying the
same "a named regulator took a real action" bar the rest of the schema already uses.

**9.1.1 — Multi-source notes.** Whenever two or more sources — any combination of the
four Tier-I regulators, or a non-Tier-I body under §10.1a — have a stance on the same
excipient, a note surfaces stating each position as fact, at equal weight, with no
ranking and no editorializing on which is correct. This fires on agreement as well as
disagreement, not only on conflict. A regulator that simply hasn't ruled is not a
"stance" and generates no note. The note never changes the score; only §9.1's Tier-I
action does that, independent of whether a note is also showing.

Example note copy: *"IARC (WHO) classified titanium dioxide as [category] in [year]. No
FDA or EFSA action has followed."* Never *"WHO banned it"* — WHO has no enforcement
authority in any jurisdiction, and overstating that is the same accuracy failure as
understating a Tier-I regulator's actual action.

**9.1.2 — Undeclared vs. declared allergens.** An **undeclared** allergen is a labeling
violation and almost always already reaches Provenix as an FDA recall or warning
letter — it rides the *existing* `recalls` / `warning_letters` pipeline and scores
through the mechanism those tables already feed into `regulatory_compliance`. The
excipient layer does not create a second, parallel scoring row for the same
underlying event — it only tags which excipient caused it, for display attribution
("recalled for undeclared milk"). A **declared** allergen is a compatibility flag
under §9.2, not a regulatory flag — see there.

**9.2 — Compatibility flags.** Dietary practice signals: gelatin source (bovine,
porcine, fish, plant-derived HPMC), carmine, shellac, beeswax, declared allergens
(lactose, gluten-bearing carriers, tree nuts, etc.). These are identity/disclosure
signals, not risk signals. They **never** touch the Trust Score under any
circumstance. They render only through the personalization layer in §11, to a
signed-in user whose stated dietary practices match — e.g. *"Contains porcine
gelatin — conflicts with your halal preference."*

**9.3 — Contested excipients.** Magnesium stearate, carrageenan, silicon dioxide, and
others where consumer anxiety exceeds the evidence. We list them when present. We
assign no risk characterization, no flag, no score effect, and no cautionary framing.
**This is a hard rule with no exception path.** An excipient leaves this category in
one direction only: a Tier-I regulator in §10.1 acts, at which point it becomes a
regulatory flag under §9.1.

**9.4 — Certification icons (new in v0.5).** Kosher, halal, vegan, non-GMO, and
gluten-free status render as icons on every product page, visible to all visitors —
**no personalization, no sign-in required.** An icon appears **only when a real
third-party certification exists** (e.g. OU/Star-K/Kof-K for kosher, IFANCA/ISNA for
halal, Certified Vegan/Vegan Action, GFCO for gluten-free). Provenix never infers a
practice-compliance icon from an ingredient list — an absent icon means "no verified
certification found," never "fails this practice." Kosher and halal status in
particular depend on facts an ingredient list can't disclose (shared equipment,
supervision, cross-contamination controls), so an inference would be a claim Provenix
hasn't actually verified. This is structurally distinct from and additive to §9.2's
compatibility flags: an icon is a strong, certified, universal claim; a compatibility
flag is a weaker, ingredient-inferred, personal one. A product can carry both at once
for different practices.

## §10 Source hierarchy — published

Published openly on the marketing site and in-app so we can be held to it.

| Tier | Source | Permitted use |
|---|---|---|
| **I** | Regulatory action by FDA, EFSA, Health Canada, or TGA | May influence the Trust Score |
| **II** | Peer-reviewed systematic reviews and meta-analyses | Contextual display only — never scored |
| **III** | Single studies, animal studies at non-physiological doses, industry-funded research | Does not appear in the product at all |

**10.1a — International bodies (WHO, IARC, and similar).** Not a regulator — no
jurisdiction, no enforcement authority anywhere. Cited under §9.1.1's multi-source note
mechanism only, at the same "contextual display only, never scored" permission as Tier
II, never as a Tier I substitute. A WHO/IARC classification can trigger a note on its
own even with zero Tier-I regulators involved; it can never trigger a score change on
its own or in combination with anything else.

The three-column rule stated plainly: **regulatory facts move scores, scientific
consensus and international-body positions inform display, contested or emerging
evidence does not ship.**

Tier II never promotes itself to Tier I. A systematic review moves a score only once a
Tier I regulator has acted on the underlying evidence. The regulator's action is the
trigger, not the strength of the literature. Same rule for §10.1a bodies.

## §10.4 Anti-EWG guardrails

The failure mode we are designing against is hazard-based rather than risk-based
rating: flagging a substance because harm has been demonstrated under some condition,
at some dose, in some organism, without asking whether a human consumer encounters
anything near that exposure. Four structural guardrails:

1. **Published hierarchy** (§10) — external and auditable, not an internal norm.
2. **Dose-reality check** — a mandatory gate in the review workflow, per §9.1's Tier-I
   bar. Before any excipient generates a flag, the reviewer answers on the record: *at
   the concentration present in a typical serving, does this present a plausible human
   risk at the exposure level the primary regulatory source established?*
3. **Schema-level separation** of regulatory fact from scientific/international-body
   opinion (§10.5).
4. **Public methodology versioning** — every flag added or removed is logged with its
   date, its trigger, and its effect on scores, visible to users.

## §10.5 Schema-level separation

Enforced structurally, not by convention:

- Score computation reads from a single view exposing every Tier-I `regulatory_actions`
  row, regardless of which of the four regulators it's from — **no regulator filter**.
  No other table, and no non-Tier-I source, has a path into scoring.
- The contested-excipient table has **no risk, severity, or concern column**.
- Scientific-opinion and international-body records (systematic reviews, WHO/IARC)
  live in one shared contextual-sources table, distinguished by a `source_type` field,
  whose only permitted render target is the §9.1.1 multi-source note or a product-page
  footnote.
- A migration test asserts these boundaries and fails CI if a future migration opens a
  path between them.

## §10.6 Score architecture (new in v0.5)

Excipient regulatory flags (§9.1) score **inside the existing `regulatory_compliance`
subscore**, as one more penalty type alongside recalls, inspections, regulatory
actions, warning letters, and NDI flags — same per-type-cap pattern already in
`scoreRegulatoryCompliance`. This deliberately avoids a seventh top-level subscore: no
new entry in the composite-score weight table, no rebalancing of the other six weights,
no model-v2 event at the composite level. It's a smaller, contained addition to a
subscore that already moves whenever new records are added — not a new kind of
volatility, just a new input into an existing one.

To keep this from quietly blurring Provenix's core differentiator — manufacturer
identity, not ingredient safety scoring — the product page must display
`regulatory_compliance` as **two visually separated, labeled groups feeding one
number**: *Facility & manufacturer record* (recalls, inspections, regulatory actions,
warning letters) and *Ingredient regulatory flags* (§9.1 excipient actions). One
subscore, two legible stories.

## §11 Personalization layer — Phase 2

A preference profile sitting **alongside** the Trust Score, never inside it. The Trust
Score stays universal, objective, and identical for every user. The compatibility
layer (§9.2) is personal, and the UI states plainly that it is personal — this is
separate from and in addition to §9.4's universal certification icons.

**11.1 — We never collect religious affiliation.** We ask instead: *do you follow any
of these dietary practices?* — halal, kosher, vegan, vegetarian, gluten-free,
carnivore, and others as relevant. There is no religion field in the schema and no
derived field that reconstructs one.

**11.2 — Flag rendering.** "Contains porcine gelatin — conflicts with your halal
preference." The Trust Score does not move. The flag appears or does not based solely
on the user's own profile. §9.4's certification icons render independently of this and
require no profile at all.

**11.3 — B2B / practitioner-side profiles: deferred, not built for Phase 1.** The
Phase-1 pilot (2–3 functional medicine practices) does not ship a "practitioner applies
dietary requirements across recommended products for a patient" workflow. A
practitioner recording a patient's dietary practice is a third party storing what can
function as a near-proxy for religious affiliation in a clinical-adjacent record — a
different risk profile than a consumer self-selecting their own preferences, and one
worth a counsel review before it's built, not before it's deferred. Revisit only if a
pilot practice actually asks for it.

**11.4 — Timing.** Preference schema (§9.2/§11's consumer side) lands in the data model
now, per Build Prompt 3.4. UI ships when SKU count makes personalization useful,
~500+ products. §9.4's certification icons are not gated on this timeline — they ship
as soon as `certifications` carries real cert data, independent of accounts or
preferences.

---

# Part 2 — CLAUDE.md / AGENTS.md addendum

Already appended to `AGENTS.md` — reproduced here for the record.

```
## Excipient layer — hard rules

- Three categories, never blended: regulatory flag (scoreable via Tier I only),
  compatibility flag (never scoreable, personal), contested (list only, no
  characterization).
- Any single Tier-I regulator's action (FDA, EFSA, Health Canada, TGA) scores on its
  own merits — never gated on which one acted, never gated on whether the others
  agree, disagree, or are silent.
- WHO, IARC, and other non-Tier-I bodies NEVER score, alone or in combination with
  anything else. They generate a display-only note whenever paired with any other
  source (Tier I or not) that also has a stance on the same excipient.
- A multi-source note fires on ≥2 stances, agreement or disagreement alike, always at
  equal weight, never ranked, never editorialized.
- Undeclared allergens ride the existing recalls/warning_letters pipeline — never a
  second, parallel scoring row for the same event. The excipient layer only tags which
  ingredient caused it, for display.
- Declared allergens are compatibility flags (personal, never scored) — not the same
  mechanism as undeclared allergens.
- Certification icons (kosher/halal/vegan/non-GMO/gluten-free) are universal, no
  sign-in required, and appear ONLY when backed by a real third-party certification.
  Never inferred from an ingredient list. Absence means "no certification found," never
  "fails this practice." Fully separate from compatibility flags — a product can carry
  both.
- Excipient regulatory flags score inside `regulatory_compliance` as a new penalty
  type (same per-type-cap pattern as recalls/inspections/warning letters). No new
  top-level subscore, no reweighting the other six. Display it as two labeled groups
  (facility/manufacturer record vs. ingredient flags) feeding one number, not blended.
- No religion field. No field from which religious affiliation can be derived. Users
  select dietary practices; that is the whole model.
- No practitioner-side (B2B) dietary profile in Phase 1. Don't build it speculatively.
- Every flag carries its regulator (or "WHO/IARC" for non-Tier-I notes), jurisdiction,
  effective date, citation URL, and the methodology version under which it was added.
- Adding or removing a flag, or adding a new penalty type to a subscore, is a
  versioned, publicly logged event. Never a silent data edit.
```

---

# Part 3 — Build prompts

### 3.1 — Schema

```
Extend the Supabase schema for the excipient layer. Migrations only, no UI.

Tables:
- excipients — canonical registry, one row per substance, with synonyms and
  identifiers (CAS, E-number, INS) for resolution
- product_excipients — SKU to excipient, with how we learned it (label OCR, label
  filing, manufacturer disclosure) and a confidence value
- regulatory_actions — regulator enum (FDA | EFSA | HEALTH_CANADA | TGA),
  action_type, jurisdiction, effective_date, citation_url NOT NULL, subject
  excipient, methodology_version_added. ALL rows here are scoreable — no filtering
  by which regulator.
- allergen_excipient_links — join from an existing recalls/warning_letters row to the
  excipient that caused it (undeclared allergen case). Display attribution only; does
  NOT feed scoring on its own — the underlying recall/warning_letter row already does.
- contextual_sources — systematic reviews, meta-analyses, AND WHO/IARC-type
  international body statements, distinguished by a source_type enum. Footnote /
  multi-source-note render only. No risk, severity, or score-relevant column.
- dietary_attributes — excipient to attribute (porcine, bovine, fish, insect-derived,
  dairy, gluten-bearing, alcohol-derived, plant-only) — feeds §9.2 compatibility
  flags only, never scoring.
- contested_excipients — excipient reference, listed_since, and NOTHING ELSE
- methodology_versions and methodology_changelog — public, append-only
- user_dietary_practices — user to practice enum

Also extend the existing `certifications` table (do not create a parallel table) with
a `cert_category` enum (kosher | halal | vegan | non_gmo | gluten_free) and a
free-text `certifying_body` field (mirrors why `regulatory_actions.agency` is free
text elsewhere in this schema — the set of certifying bodies, OU vs. Star-K vs.
IFANCA, is open-ended).

Structural requirements, in this order of importance:

1. Score computation reads from ONE view that exposes every row of
   regulatory_actions, unfiltered by regulator, joined into the existing
   regulatory_compliance penalty calculation as a new penalty type with its own cap
   — NOT a new top-level subscore. No other table, and no contextual_sources row
   regardless of source_type, has any path into scoring.
2. contested_excipients has no risk, severity, concern, or note column. Do not add
   one for future flexibility. The absence is the feature.
3. dietary_attributes has no path into scoring. Enforce it, don't just intend it.
4. certifications.cert_category rows have no path into scoring either — icons are
   purely a display query, never a Trust Score input.
5. Write migration tests asserting 1–4 and wire them into CI so a future migration
   that opens a path fails the build. This is the single most important deliverable
   in this step — the separation has to survive people who weren't in this
   conversation.
6. methodology_changelog is append-only. No updates, no deletes, enforced at the
   database level.

Show me the migrations, the scoring view (including how it composes into
scoreRegulatoryCompliance as a new penalty type), and the tests. Flag anywhere the
design lets regulatory fact and scientific/international-body opinion touch.
```

### 3.2 — Dose-reality gate

```
Build the excipient flag review workflow.

A proposed regulatory flag cannot reach published state without a completed
dose-reality check. Store the reviewer's recorded answer to: at the concentration
present in a typical supplement serving, does this present a plausible human risk at
the exposure level the primary regulatory source established?

- The check is a required field, not a checkbox. Capture the reasoning text and the
  exposure figures considered.
- A flag whose supporting evidence is animal data at non-physiological doses is
  rejected by the workflow, and the rejection is recorded and queryable.
- Every published flag links to its completed check. The check is internal, but it
  must be producible on request — this is what we point to if the methodology is
  ever challenged.
- This gate applies to Tier-I regulatory_actions rows only. contextual_sources rows
  (WHO/IARC, systematic reviews) don't score, so they don't need a dose-reality gate
  to publish — they need a citation, full stop.

Show me the state machine and the review queue schema.
```

### 3.3 — Methodology versioning

```
Build public methodology versioning.

- Every flag addition or removal writes an immutable changelog entry: what changed,
  which regulator triggered it, effective date, which version introduced it, and how
  many SKU scores moved as a result.
- The addition of excipient regulatory flags as a new regulatory_compliance penalty
  type is itself a changelog-worthy event — log it the same way, even though it isn't
  a full composite-score reweight.
- Scores already carry their methodology version. Ensure any score can be explained
  under the version that produced it, even after recalibration.
- Build the public-facing changelog view. Plain language, reverse chronological,
  no auth required.

This is a product surface, not an internal audit log. Treat it as user-facing.
```

### 3.4 — Preference schema (no UI)

```
Implement the dietary preference schema only. No UI this phase.

- Practices as an enum: halal, kosher, vegan, vegetarian, gluten_free, carnivore,
  extensible.
- No religion field. No field from which religious affiliation could be derived.
  If a column you are about to write would let someone infer religious affiliation
  from a dietary selection plus one join, stop and tell me before writing it.
- Compatibility resolution runs as a pure function of (user practices,
  product dietary_attributes). It takes no score input and produces no score output.
- This is entirely separate from certifications.cert_category (§9.4 icons) — do not
  let the two mechanisms share a table or a resolution path. Icons are universal and
  certification-sourced; this schema is personal and inference-sourced.
- No practitioner/B2B table in this pass — user_dietary_practices is consumer-only.
- RLS: a user's practices are readable only by that user.

Show me the schema, the resolution function, and the RLS policies.
```

### 3.5 — Product page display

```
Build the excipient display layer on the product page, in the current direction's
tokens.

Four visually distinct treatments — a user must never have to work out which
category something belongs to:

- Regulatory flags: prominent, with regulator name, jurisdiction, action, and date
  visible without a tap. Displayed as two labeled groups inside the regulatory
  compliance section — facility/manufacturer record vs. ingredient regulatory flags
  — feeding one subscore number, not blended into an undifferentiated total.
- Multi-source notes: whenever ≥2 sources (Tier I or WHO/IARC) have a stance on the
  same excipient, show every statement at equal visual weight, no ranking. "EFSA
  removed this from permitted food additives in 2022. FDA has not acted." "IARC
  classified X as [category] in [year]." No editorializing on any of them.
- Certification icons: a row on every product page, visible with no sign-in. Only
  render an icon when a real certifications.cert_category row backs it. No icon for
  an uncertified product — never render a negative/red state implying it fails the
  practice. A small standing note near the row should say certification-only,
  absence-isn't-failure, once, plainly.
- Compatibility flags: rendered only when the user's profile calls for them, and
  visibly marked as personal. "Based on your preferences" must be on screen. Never
  styled or iconified the same way as a certification icon — this is the weaker,
  inferred, personal claim, and it needs to read that way.
- Contested excipients: listed in a plain ingredient list. No icon, no color, no
  warning styling, no separate card. Styling that implies concern is the same
  failure as writing a warning.

Copy stays evidentiary throughout — what the record says, never what we think.
Show me layouts first and wait.
```

---

# Decisions log — Part 4, settled 2026-08-05

| # | Question | Resolution |
|---|---|---|
| 1 | Does regulatory divergence move the score? | No. Any Tier-I regulator's action scores on its own merits regardless of what others say or don't say. Non-Tier-I bodies (WHO/IARC) never score. Divergence/agreement between ≥2 sources generates a display-only note, equal weight, no ranking. |
| 2 | Allergens misfiled? | Undeclared → existing recall/warning-letter pipeline, excipient layer tags for display only, no double-scoring. Declared → compatibility flag (§9.2), personal, never scored — kept as a separate mechanism from certification icons (§9.4), not folded into them. |
| — | (sub-decision) Icons for kosher/halal/vegan/etc. | Universal (no sign-in required), certified-only (no ingredient inference), absence ≠ negative claim. Coexists with, doesn't replace, §9.2 compatibility flags. |
| 3 | New subscore or fold into regulatory_compliance? | Fold in as a new penalty type inside `regulatory_compliance` — no top-level reweight, no model-v2 event. Displayed as two visually separated labeled groups (facility/manufacturer vs. ingredient flags) so the "who made it" positioning stays legible in the UI even though the score is unified. |
| 4 | Practitioner-side (B2B) profiles / HIPAA exposure? | Deferred entirely for Phase 1 — not built for the pilot. Sidesteps the legal question rather than needing an answer this week; revisit only if a pilot practice actually asks for it. |
| 5 | Novelty claim overstated for investors? | Narrowed to "nobody scores who made it" (manufacturing provenance and facility compliance), rather than claiming the Trust Score itself is globally novel — Labdoor/ConsumerLab/USP/NSF already run scoring/certification schemes on the product-in-the-bottle. |
