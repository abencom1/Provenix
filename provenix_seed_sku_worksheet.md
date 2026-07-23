# Provenix — Seed SKU Research Worksheet

**Purpose:** hand-verify 12 real products so the Trust Score has something to render against.
This is research, not code. Every field below gets filled from a **primary source** — not from
memory, not from a summary, not from an AI. Provenix publishes compliance claims about named
companies; the whole defamation posture depends on each field tracing to a document you can point at.

**Nothing in this file is a claim.** These are candidates *to research*. Certification status,
ownership, and manufacturing arrangements change often — verify all of it fresh.

---

## How to work through this

Don't fill all 12 at once. Do **#1, #7, and #10 first** — one easy, one moderate, one unresolved.
Load those three into Supabase, render a score, and confirm the "insufficient data" state looks
right. You'll almost certainly find a schema gap. Fixing it with 3 rows loaded is cheap; with 12
it's annoying. Then batch the rest.

---

## Tier A — attribution should resolve cleanly
*Vertically integrated (brand owns the plant) or third-party certified, so the facility is
knowable. These prove the happy path and should produce your highest-confidence scores.*

| # | Candidate | Category | Why it's here | Expected to test |
|---|---|---|---|---|
| 1 | Nature Made Vitamin D3 | Vitamin | Pharmavite is brand *and* manufacturer — simplest possible attribution | `confidence = high`, USP cert lookup |
| 2 | NOW Foods Magnesium Citrate | Mineral | Owns its manufacturing; publishes in-house testing | High mfr transparency subscore |
| 3 | Thorne Vitamin D / Basic Nutrients | Vitamin | Owns manufacturing; several SKUs certified | NSF Certified for Sport path |
| 4 | Optimum Nutrition Gold Standard Whey | Sports nutrition | Large, certified, widely scanned | Sports-nutrition category, cert lookup |
| 5 | Nordic Naturals Ultimate Omega | Vitamin (oil) | Publishes per-lot CoAs | **Tier 4 lab testing** — the top testing tier |
| 6 | Ritual Essential for Women | Multivitamin | Voluntarily publishes supplier info — rare | Max `manufacturer_transparency` |

## Tier B — contract manufactured, discoverable with work
*Brand ≠ manufacturer. Attribution takes digging and may land at `moderate` confidence, or
unresolved. This is the realistic middle.*

| # | Candidate | Category | Why it's here | Expected to test |
|---|---|---|---|---|
| 7 | Garden of Life multivitamin | Multivitamin | Large brand, mixed contract manufacturing | `confidence = moderate` path |
| 8 | Nature's Bounty Fish Oil | Vitamin (oil) | High volume, contract manufactured | Attribution from enforcement records |
| 9 | Kirkland Signature Vitamin D3 | Vitamin | Private label — brand deliberately obscures maker | Private-label attribution |

## Tier C — expect unresolved
*Marketplace and proprietary-blend products. These are where FDA enforcement, NDI issues, and
adverse events actually cluster — and where most scanned products will live.*

| # | Candidate | Category | Why it's here | Expected to test |
|---|---|---|---|---|
| 10 | Amazon-native ashwagandha or turmeric | Botanical | No public manufacturer | **`facility_id` NULL, `is_scorable` false** |
| 11 | Store-brand botanical (any retailer) | Botanical | Private label, botanical enforcement risk | Import alert (category-level scope) |
| 12 | Proprietary-blend pre-workout or "test booster" | Sports nutrition | Blend hides doses; enforcement-heavy segment | Low ingredient transparency, NDI flag, adverse events |

---

## Fields to fill per product — and where each comes from

**Identity**
- GTIN / barcode → scan the physical bottle, or Open Food Facts
- Brand name, product name → the label itself

**Brand & facility**
- Brand legal entity, address, website → brand's own site / corporate filings
- Facility name, address, country → see attribution sources below
- FEI number → FDA establishment registration data

**Manufacturer attribution** *(the hard part — this is the product)*
Source priority, best first:
1. **NSF listing** — NSF's own public lookup tool. Manual lookup only; their ToS forbids scraping.
2. **Enforcement record** — an FDA warning letter or recall naming both brand and facility
3. **Direct outreach** — email the brand and ask. Log the reply.
4. **Label photo** — some labels state "Manufactured for / Manufactured by"
5. **Inferred** — lowest confidence; record the reasoning in `source_detail`

If none of these land: leave `facility_id` NULL. **Unresolved is a legitimate, honest answer.**
Guessing is the one thing that gets you sued.

**Regulatory records** (all per-facility or per-brand, each with its own retrieval date)
- Warning letters → FDA warning letter database
- Import alerts → FDA import alert list. Record `facility_specific` vs `category_level` — they
  are weighted differently and conflating them is a real accuracy failure.
- Recalls → FDA recall feed, detail from openFDA
- NDI flags → FDA's public NDI notification log. Remember the required context: **absence of a
  notification is not itself a violation.**
- Adverse events → openFDA HFCS. Always rendered with FDA disclaimer context.

**Testing & certification**
- Lab testing tier (1–4) → does the brand publish CoAs? Per lot, or generic? Is there a public
  lot-lookup tool? Tier 4 requires per-lot public lookup.
- Certifications → verify on the certifier's own site (NSF, USP, Informed Sport). Never trust
  a badge image on the brand's marketing page — verify at the source, capture the URL.

---

## Rules while researching

1. **Record the source URL and the date you checked it** for every single field. Your schema has
   `source` and `retrieved_at` columns on every enrichment table for exactly this reason.
2. **Blank beats guessed.** NULL renders as "insufficient data," which is honest. A wrong facility
   attribution is a false compliance claim about a named company.
3. **Facility-specific vs category-level import alerts are not the same thing.** Don't collapse them.
4. **If a fact surprises you, re-verify before entering it.** Surprising findings are the ones that
   end up in a screenshot.

---

## When the first three are done

Send them back and I'll write the INSERT statements — they span ~8 related tables with foreign
keys and the versioned attribution row, so it's worth generating rather than hand-typing.
