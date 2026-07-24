# Provenix — Seed SKU Research Findings (working log)

Research notes only — not final DB values. Once #1, #7, and #10 are done, generate the
INSERT statements per `provenix_seed_sku_worksheet.md`.

---

## #1 — Nature Made Vitamin D3 2000 IU (50 mcg) Softgels — Item #2585

**Status: UPDATED by migration 001 (2026-07-22) — confidence = moderate, company-level**
(supersedes the original "confidence = low" call below; see
`provenix_migration_001_attribution_facilities.sql`). Two of the six FDA-registered facilities are
explicitly named "Pharmavite LLC dba Nature Made" — that's primary-source confirmation Pharmavite
is the manufacturer at the company level, even though the specific plant is still unknown. All 6
FEI facilities are now linked via `manufacturer_attribution_facilities` with none marked primary,
so regulatory-compliance scoring rolls up across all 6 rather than requiring one plant to be named.

**Original research (below), before the company-level rollup mechanism existed:**

- Brand: Nature Made (Pharmavite LLC)
- Label distributor address (screenshot, NatureMade.com, retrieved 2026-07-22): "Nature Made
  Nutritional Products, West Hills, CA 91309-9903" — labeled "Distributed by," not "Manufactured
  by."
- DSLD label record (id 12154, `dsldapi.od.nih.gov`, retrieved 2026-07-22): same distributor
  contact, typed `"Distributor"` — confirms no manufacturer disclosure on the label itself. Note:
  this DSLD entry is an older, off-market package variant.
- Candidate facilities (FDA Data Dashboard `inspections_classifications`, filtered
  `LegalName: ["Pharmavite LLC"]`, retrieved 2026-07-22) — 6 distinct FEI numbers found, all NAI/VAI,
  none OAI:
  - FEI 2016744 — Pharmavite LLC dba Nature Made — San Fernando, CA
  - FEI 2018618 — Pharmavite LLC — West Hills, CA (8531 Fallbrook Ave, 91304)
  - FEI 2027108 — Pharmavite LLC — Valencia, CA
  - FEI 3000950981 — Pharmavite LLC dba Nature Made — Santa Clarita, CA
  - FEI 3009943839 — Pharmavite LLC - Opelika — Opelika, AL
  - FEI 3030170485 — PHARMAVITE LLC — Johnstown, OH
- **Why unresolved:** label's distributor city (West Hills) matches FEI 2018618's city, but the
  ZIP codes differ (label: 91309-9903, a PO-box-style ZIP; FEI record: 91304, a street address) —
  not strong enough to call it a match. Company-name matching alone returns 6 candidate facilities,
  not one.
- **Not yet tried:** USP Verified product directory lookup (usp.org / quality-supplements.org),
  direct outreach to Nature Made (1-800-276-2878 / NatureMade.com).
- `source_type` if entered now: `inferred` (weakest tier) or leave `facility_id` NULL entirely —
  recommend NULL given how thin the West Hills match is.

---

## #7 — Garden of Life Vitamin Code Women — UPC 6 58010 11417 2

**Status: RESOLVED / confidence = moderate**

- Brand: Garden of Life LLC
- DSLD label record (id 321402, `dsldapi.od.nih.gov`, retrieved 2026-07-22, currently on-market):
  distributor contact "Garden of Life LLC, 4200 Northcorp Parkway, Palm Beach Gardens, FL 33410" —
  labeled "Distributed by," not "Manufactured by."
- Candidate facilities (FDA Data Dashboard `inspections_classifications`, filtered
  `LegalName: ["Garden of Life LLC", "Garden of Life"]`, retrieved 2026-07-22) — 3 distinct FEI
  numbers, all NAI/VAI, none OAI:
  - **FEI 3011330545 — Garden Of Life, LLC — 4200 Northcorp Pkwy Ste 200, West Palm Beach, FL 33410**
    (most recent inspection 2024, NAI)
  - FEI 3010543257 — Garden of Life — 1335 53rd St, Mangonia Park, FL 33407
  - FEI 3011711592 — Garden Of Life Llc — 114 Tri County Dr, Freedom, PA 15042
- **Why moderate (not high):** FEI 3011330545's street address, suite, and ZIP match the label's
  distributor address exactly (city name differs — "West Palm Beach" vs. "Palm Beach Gardens" — but
  both refer to the same business park in FDA/USPS records, not a real discrepancy). Stronger than
  a coincidental city match, but an FDA-registered establishment at a company's corporate address
  doesn't rule out that manufacturing/encapsulation happens at one of the other two registered
  facilities (Mangonia Park or Freedom, PA) instead.
- `facility_id`: FEI 3011330545 (4200 Northcorp Pkwy Ste 200, West Palm Beach, FL 33410)
- `source_type`: `inferred` (address-matched against FDA registration/inspection data — not a
  document naming brand and facility together, which is what `enforcement_record` specifically
  means per this worksheet's own definition; corrected from an earlier mis-tag)
- **Not yet tried:** USP/NSF lookup, direct outreach — would be needed to move this to `high`.

---

## #10-substitute — Thorne Ashwagandha (Shoden® extract)

**Note:** substituted for the worksheet's original #10 candidate at Aaron's direction. Thorne is
Tier A ("should resolve cleanly"), not Tier C — this SKU does **not** exercise the
`facility_id = NULL` / "insufficient data" path the worksheet specifically wanted tested before
scaling to 12. A genuinely unresolved marketplace product (Amazon-native botanical, no public
manufacturer) is still owed before batching the rest.

**Status: RESOLVED / confidence = high**

- Brand: Thorne Research, Inc.
- Product: Ashwagandha, ashwagandha extract (root, leaf) *Withania somnifera*, 120 mg/capsule,
  using Arjuna Natural Pvt. Ltd.'s "Shoden®" branded extract (ingredient-transparency data point,
  separate from facility attribution).
- Label (screenshot, thorne.com product page, retrieved 2026-07-22): **"manufactured by: Thorne
  Research, Inc., Summerville, SC 29486, 1-800-228-1966"** — uses "manufactured by," not
  "distributed by."
- FDA Data Dashboard (`inspections_classifications`, filtered `LegalName` variants of Thorne
  Research, retrieved 2026-07-22): **only one manufacturing FEI found** — 3014491710, 620 Omni
  Industrial Blvd, Summerville, SC 29486 — address matches the label exactly. 7 inspections
  2011–2024, mostly NAI, one VAI, none OAI. A second FEI (3016068508) is explicitly labeled "West
  Coast Distribution Benicia — Thorne Research," Benicia, CA — clearly distribution, not
  manufacturing, so correctly excluded.
- `facility_id`: FEI 3014491710 (620 Omni Industrial Blvd, Summerville, SC 29486)
- `source_type`: `user_photo` (label screenshot)
- Confirms the Tier A hypothesis: a single vertically-integrated manufacturer with a direct label
  statement resolves cleanly, unlike #1 (Pharmavite, 6 candidate facilities) or #7 (Garden of Life,
  3 candidate facilities).

---

## #10 — FGO Organic Ashwagandha Root Powder

**Status: RESOLVED AS UNRESOLVED / confidence = NULL, zero candidate facilities**

- Brand: FGO (Amazon listing: amazon.com/dp/B01D9OS7MG)
- Product: Organic Ashwagandha Root Powder, 16oz resealable bulk bag, sourced from India,
  Non-GMO. Single ingredient: ashwagandha root powder (*Withania somnifera*).
- Amazon listing (retrieved 2026-07-22): no manufacturer/distributor info visible on the page
  itself; no NSF, USP, or Informed Sport certification claimed.
- DSLD label record (id 265392, `dsldapi.od.nih.gov`, retrieved 2026-07-22, on-market): distributor
  contact is just **"FGO, Seattle, WA 98117"** — no street address at all, no legal entity suffix
  (no "LLC"/"Inc"), just the brand name and a city/ZIP. `upcSku` on file is `X000ZISJBP`, an
  ASIN-shaped identifier rather than a real UPC/GTIN — itself a small transparency signal (no real
  barcode was ever registered).
- FDA Data Dashboard (`inspections_classifications`, filtered `LegalName: ["FGO"]`, retrieved
  2026-07-22): **zero results.** No FDA-registered facility exists under this name at all — unlike
  Pharmavite (6 candidates) or Garden of Life (3), there is nothing to narrow down.
- `manufacturer_attribution_facilities`: zero rows (empty candidate set, distinct from #1's "6
  candidates, none primary" case — this is "0 candidates, nothing found").
- **Why this is the right #10:** confirms there's a genuine, real-world "insufficient data" case,
  not just attribution ambiguity — the private-label reseller almost certainly has no direct
  relationship with (or knowledge disclosed about) whatever contract manufacturer actually
  processes the powder.

---

## Recalls (openFDA `food/enforcement.json`, retrieved 2026-07-22)

Pulled via `recalling_firm` search for each of the 4 brands. Loaded in
`provenix_seed_recalls_batch1.sql`, linked at `brand_id` (not `product_id`) since none match the
exact seeded SKUs — same brand-vs-SKU distinction as facility attribution.

- **Pharmavite/Nature Made: 18 recalls**, all Class II, all status "Terminated." Two clusters: 4
  from 2013-09-09 (B1/B12 potency, "Multi" softgel line) and 14 from 2016-06-06 (Salmonella,
  Staph aureus, yeast/mold across various Vitamin D, B-Complex, and gummy lines). None are the
  exact 2000 IU/50 mcg softgel SKU researched — closest are several "D3 1000IU" recalls (different
  dosage).
- **Garden of Life: 8 recalls** — **4 are Class I** (most severe tier), not all Class II: 3
  Salmonella recalls in "Raw Meal" powder (2016-01-29) plus a choking-hazard notice on a baby
  liquid probiotic (2017-09-07). The other 4 are Class II, undeclared soy (2023-10-19, "RM-10
  Ultra"). None are the Vitamin Code Women SKU.
- **Thorne: 0 recalls.** **FGO: 0 recalls.** No rows inserted for either — absence noted, not
  fabricated as "clean."

---

## Warning letters (FDA Data Dashboard `compliance_actions`, retrieved 2026-07-22)

Queried all 10 known FEI numbers (6 Pharmavite, 3 Garden of Life, 1 Thorne) in one request.
**Zero results.** No rows to insert — genuinely clean by this measure for every facility on file.

## Adverse events (openFDA CAERS `food/event.json`, retrieved 2026-07-22)

Counted reports where `products.role = "SUSPECT"` and `products.name_brand` contains the brand
name (excludes reports where the brand was only a CONCOMITANT/co-mentioned product). Loaded in
`provenix_seed_adverse_events_batch1.sql`, linked at `brand_id` since CAERS reports span many
products per brand, not the 4 exact seeded SKUs.

| Brand | SUSPECT-role reports |
|---|---|
| Nature Made | 497 |
| Garden of Life | 107 |
| Thorne | 51 |
| FGO | 1 |

Per CAERS's own disclaimer (and the schema's display rule): these counts cannot be used to draw a
causal relationship, and a single report listing multiple products cannot have its reaction
attributed to one specific product. Must always render with that context, never as a raw count.

---

## Remaining worksheet SKUs (#2–#6, #8, #9, #11, #12) — retrieved 2026-07-23

All researched via the same DSLD → FDA Data Dashboard pipeline. This completes all 12 worksheet
SKUs (#1, #7, #10 done earlier).

### #2 — NOW Foods Magnesium Citrate — UPC 7 33739 01294 4

**Confidence: high, single facility.** DSLD label record (id 313576) contact type is directly
**"Manufactured by"** (not "Distributor," unlike Nature Made/Garden of Life): NOW FOODS, 395 S.
Glen Ellyn Rd., Bloomingdale, IL 60108. FDA Data Dashboard (`LegalName: NOW Foods` / `NOW Health
Group`) confirms FEI 1482865 at "395 Glen Ellyn Rd, Bloomingdale, IL 60108" — exact match (17
inspections 2009–2025, mostly NAI, some VAI, none OAI). Two other NOW-related FEIs exist (244
Knollwood Dr, different address — corporate/admin; 1620 Central Ave Roselle, explicitly "NOW
Foods - Distribution Center") — correctly excluded as clearly different functions, not genuine
candidates. `facility_id`: FEI 1482865, `is_primary = true`. `source_type`: `user_photo` (DSLD's
own manufacturer-typed contact counts as a direct label statement, same tier as a screenshot).

### #3 — Thorne Vitamin D (liquid drops) — UPC 6 93749 16801 0

**Confidence: high, reuses Thorne's known facility** (FEI 3014491710, Summerville SC — same as
#10 Ashwagandha, confirmed there via label photo). DSLD contact (id 298102) reads "Manufactured in
the USA... for Thorne Research, Inc." typed as Distributor, no address given — thinner than the
Ashwagandha label, but Thorne is a single vertically-integrated manufacturer already confirmed by
direct photo evidence, so the same facility applies by brand consistency rather than fresh
per-SKU proof.
**Caveat:** this specific SKU's DSLD data shows no NSF Certified for Sport claim, so it does not
exercise the cert-lookup path the worksheet wanted tested for #3 — a different Thorne SKU would be
needed for that specific test.

### #4 — Optimum Nutrition Gold Standard 100% Whey (Double Rich Chocolate) — UPC 7 48927 05226 8

**Confidence: high, single facility.** DSLD contact (id 308405) is "Manufactured by": Optimum
Nutrition, 3500 Lacey Road, Suite 1200, Downers Grove, IL 60515. FDA Data Dashboard
(`LegalName: Optimum Nutrition` / `Glanbia Performance Nutrition`) returns 7 distinct facilities
total; one — **FEI 3016573922, "Glanbia Performance Nutrition Manufacturing Inc"** — has
"MANUFACTURING" explicitly in its legal name AND matches the label address exactly. The other 6
(Sunrise FL, Walterboro SC, 2x Aurora IL, Middlesbrough UK, and an Aurora IL site explicitly
labeled "Distribution Center") are differentiable by name/address/function, so excluded as
non-candidates rather than linked as ambiguous alternatives. `facility_id`: FEI 3016573922,
`is_primary = true`. `source_type`: `user_photo`.

### #5 — Nordic Naturals Ultimate Omega (Lemon) — DSLD upcSku X001GHYR7T (ASIN-shaped)

**Confidence: moderate, 2 candidates.** DSLD contact (id 313197) is "Manufactured in the U.S. by":
Nordic Naturals Mfg, Inc., 111 Jennings **Drive**, Watsonville, CA 95076. FDA Data Dashboard shows
FEI 3008880179 at "111 Jennings **Way**, Watsonville, CA" (same house number/city/state, only the
street-suffix differs — same pattern as Garden of Life's business-park naming variance) as the
best-evidenced match, `is_primary = true`. A second real manufacturing site, FEI 3003710288
"Nordic Naturals Manufacturing," 2390 Oak Ridge Way, **Vista, CA**, is a genuinely different
location also explicitly named "Manufacturing" — linked as a non-primary candidate per the rollup
standard, since it can't be ruled out for this specific SKU.

### #6 — Ritual Essential for Women (Mint Essenced)

**Confidence: NULL, unresolved — but for a different reason than FGO/Kirkland/Spring Valley.** No
FDA facility found under "Ritual" in any name variant tried (the only 3 FDA matches — "Ritual
Chocolate," "Ritual Energy LLC" — are unrelated companies). DSLD's own manufacturer contact record
(id 278454) has a "Manufacturer"-typed entry but literally no name/address populated. Ritual's own
site (ritual.com) discloses extensive **ingredient-level supplier traceability** instead — each of
9 key nutrients lists its own raw-material supplier and country of origin (e.g. Vitamin D3 from
"The GHT Companies — Nottingham, UK," Omega-3 DHA from "Algarithm Ingredients Inc. — Saskatoon,
Canada") under their "Made Traceable®" program. This is real, strong `ingredient_transparency`
data, but doesn't identify who does final encapsulation/bottling — a genuine example of a product
that could score high on one subscore and NULL on manufacturer attribution simultaneously.

### #8 — Nature's Bounty Fish Oil 1200 mg — UPC 0 74312 16887 1

**Confidence: moderate, 8 candidates, none primary.** DSLD contact (id 240786): "Carefully
Manufactured for" (Distributor-typed), Nature's Bounty, Inc., Bohemia, NY — no street address. FDA
Data Dashboard (`LegalName: Nature's Bounty` / `NBTY`) returns **8 distinct facilities** across IL,
CA, NJ, FL under the NBTY corporate family, including one explicitly named **"The Nature's Bounty
Co."** (Pompano Beach, FL) — company-level confirmation similar to Pharmavite's "dba Nature Made."
None match Bohemia, NY directly, so no single facility is marked primary; all 8 linked as
candidates per the rollup standard. `source_type`: `inferred`.

### #9 — Kirkland Signature Extra Strength Vitamin D3 2000 IU — UPC 0 96619 39391 6

**Confidence: NULL, unresolved.** DSLD contact (id 62677) shows two entries: "Distributed by:
Costco Wholesale Corporation" (a P.O. Box, not a street address) and a second contact literally
typed "Manufacturer" with **no name or address at all** — just a generic phone line ("Vitamin
Infoline," 1-800-428-7782). No legal entity name is disclosed to even attempt an FDA Data
Dashboard search. Zero candidates to link — distinct from FGO/Spring Valley in that this is a
major national retailer's private label, showing the same opacity pattern isn't limited to small
sellers.

### #11 — Spring Valley Turmeric Curcumin 500 mg (Walmart) — UPC 6 81131 15679 0

**Confidence: NULL, unresolved.** DSLD contact (id 239820): "Distributed by: Wal-Mart Stores,
Inc., Bentonville, AR" — no manufacturer disclosed at all, same pattern as Kirkland. Zero
candidates to link.
**Related but distinct finding:** FDA Data Dashboard's `import_refusals` endpoint shows 335 total
refused shipments under turmeric-related product codes (mostly raw turmeric spice/extract
shipments from India-based exporters, unrelated to Walmart's actual supplier). This is real
category-level risk context, but it is *import refusals* (individual rejected shipments), not
*import alerts* (standing DWPE orders) — the schema explicitly treats these as different concepts.
The `import_alerts` table stays empty for this SKU; the CMS_IA red-list data it needs is Tier 4
(manual/scraping only, no API) per the data-source doc.

### #12 — Cellucor C4 Original (Cherry) — UPC 8 42595 13469 8

**Confidence: NULL, unresolved.** DSLD contact (id 335104): "Cellucor and C4 are trademarks of and
Distributed by: Nutrabolt, Austin, TX" (Nutrabolt actually owns the Cellucor brand, not merely a
distributor). FDA Data Dashboard returns **zero results** for both "Nutrabolt" and "Cellucor" as
legal names — a well-evidenced null, not an unattempted search. Two proprietary blends confirmed
in the ingredient structure: "Muscular Endurance and Performance Booster" (CarnoSyn, Velox
Patented Performance Blend, PeptiPump Bioactive Lentil Peptides — no individual doses disclosed)
and "Explosive Energy and Focus Complex" (Caffeine Anhydrous, **Toothed Clubmoss Aerial Parts
Extract** — a Huperzine A source with real regulatory history, a good NDI-flag candidate). The NDI
notification log check itself is Tier 4 (manual-only), so that flag is a follow-up, not verified
here.

### Summary across all 12

| # | Product | Confidence | Candidates linked |
|---|---|---|---|
| 1 | Nature Made Vitamin D3 | moderate (company-level) | 6, none primary |
| 2 | NOW Foods Magnesium Citrate | high | 1 primary |
| 3 | Thorne Vitamin D | high (reused) | 1 primary |
| 4 | Optimum Nutrition Gold Standard Whey | high | 1 primary |
| 5 | Nordic Naturals Ultimate Omega | moderate | 2 (1 primary) |
| 6 | Ritual Essential for Women | NULL | 0 |
| 7 | Garden of Life Vitamin Code | moderate | 3 (1 primary) |
| 8 | Nature's Bounty Fish Oil | moderate | 8, none primary |
| 9 | Kirkland Signature Vitamin D3 | NULL | 0 |
| 10 | FGO Ashwagandha | NULL | 0 |
| 10-sub | Thorne Ashwagandha | high | 1 primary |
| 11 | Spring Valley Turmeric | NULL | 0 |
| 12 | Cellucor C4 Original | NULL | 0 |

5 of 12 fully unresolved, 3 high-confidence single-facility, 4 moderate with multiple linked
candidates. A realistic spread, not cherry-picked toward either extreme.

---

## Recalls and adverse events for the 8 batch-2 brands (retrieved 2026-07-23)

Same openFDA pipeline as the original 4 brands (`recalling_firm` for recalls, SUSPECT-role
`products.name_brand` match for adverse events).

**Important exclusion, same reasoning as the brand/facility split:** several corporate-parent-name
searches returned real recalls that belong to a *different sister brand* under the same
manufacturer, not the brand actually seeded. Linking these would misattribute one brand's problem
to another:
- Searching "Glanbia" returns 1 recall — for **"think!"** protein bars, a different Glanbia-owned
  brand, not Optimum Nutrition. Excluded.
- Searching "NBTY" returns 6 recalls — all for **Solgar, MET-Rx, and Pure Protein** products,
  other NBTY-owned brands, not Nature's Bounty itself. Excluded.
- Searching "Costco"/"Wal-Mart" for Kirkland Signature/Spring Valley returns recalls, but they're
  all **unrelated food-category items** (a chicken sandwich, salmon, bakery goods) under the same
  umbrella private-label name — completely different product category from the supplement SKUs
  seeded. Excluded.

**Recalls actually attributable to the seeded brand:**
- **NOW Foods: 14 recalls**, mostly Class II/III, all Terminated/Completed. Reasons span
  undeclared allergens (soy lecithin x4, gluten, pine nut, licorice/glycyrrhizin), mislabeling
  (Molybdenum mg/mcg error, B-50 label error, yeast mix-up), a contamination case (chloramphenicol
  antibiotic in digestive enzyme capsules, 2013), and one high mold/yeast/viable-count finding
  (2024).
- **Nordic Naturals: 2 recalls** — elevated Vitamin D3 levels in a baby liquid D3 product
  (2024-02-07, Class II) and a mislabeling issue in a kids' gummy multivitamin (2025-05-02, Class
  III).
- **Optimum Nutrition, Ritual, Nature's Bounty, Kirkland Signature, Spring Valley, Cellucor: 0**
  recalls attributable to the actual brand (after excluding the sister-brand/unrelated-category
  results above).

**Adverse events (SUSPECT-role reports, `products.name_brand` match):**

| Brand | SUSPECT-role reports |
|---|---|
| NOW Foods | 47 |
| Optimum Nutrition | 26 |
| Nordic Naturals | 31 |
| Ritual | 134 |
| Nature's Bounty | 548 |
| Kirkland Signature | 390 |
| Spring Valley | 322 |
| Cellucor | 69 |

Same CAERS caveat applies: no causal relationship can be drawn, and these counts must always
render with that disclaimer context, never as a raw number.

---

## Lab testing tiers and certifications (retrieved 2026-07-24)

**Certifications: DSLD label claims only, NOT verified against the certifier's own site.** Per
the worksheet's own rule (NSF's ToS forbids scraping; verify at the certifier's site, never trust
a marketing badge), I pulled these from DSLD's structured "Seals/Symbols"/formulation statements
— a legitimate public NIH source, not NSF's gatekept database — but have not clicked through
USP's/NSF's/Informed-Choice's own verification tools. Logged with `status = 'claimed_unverified'`,
`source = 'dsld_label_claim'`. **Manual verification still needed** before treating any of these
as confirmed:

| Product | Claimed cert | `certification_type` |
|---|---|---|
| Nature Made D3 | USP Verified | `usp_verified` |
| Optimum Nutrition Whey | Informed-Choice "Trusted by Sport" + banned-substance tested | `informed_choice` |
| Ritual Essential for Women | "USP verified" (in formulation text) | `usp_verified` |
| Garden of Life Vitamin Code | NSF Certified **Gluten-Free** (a specific NSF program, doesn't map cleanly to `nsf_ansi_173`/`nsf_certified_for_sport`) | `other` |
| Kirkland Signature D3 | "Dietary Supplement USP verified" | `usp_verified` |

Optimum Nutrition's claim is corroborated further by their own official support pages, which name
"Gold Standard 100% Whey" specifically as Informed-Choice certified — stronger than a label claim
alone, but still not the certifier's own database directly (that page, choice.wetestyoutrust.com,
blocked automated fetches).

**Important exclusion:** Cellucor's NSF Certified for Sport applies to **"C4 Sport"/"C4 Performance
Energy"** — a different product line from our seeded **"C4 Original."** Not applying that
certification to the seeded SKU. No certification found for: NOW Foods, Thorne (either product),
Nordic Naturals, Nature's Bounty, FGO, Spring Valley, Cellucor C4 Original.

**Lab testing tiers** — checked each brand's own site/press coverage for a public per-lot CoA
lookup (no ToS restriction on this, unlike certifications):

| Product | Tier | Why |
|---|---|---|
| Nature Made D3 | `claimed_no_public_coa` | Extensive internal testing (HPLC, IR, mass spec) and supplier CoA requirements, but no public per-lot lookup found |
| NOW Foods Magnesium Citrate | `claimed_no_public_coa` | Has a CoA portal (cofa.nowfoods.com) but it's scoped to essential oils only, not this product |
| Thorne Vitamin D / Ashwagandha | `claimed_no_public_coa` | Confirmed directly via thorne.com/quality: "4 rounds of testing," in-house labs, but no consumer lot-lookup tool |
| Optimum Nutrition Whey | `claimed_no_public_coa` | Facility-level NSF/Informed-Choice/BRCGS certs exist, no public per-lot CoA search found |
| **Nordic Naturals Ultimate Omega** | **`public_per_lot_lookup`** | Confirmed real tool at nordic.com/nordic-promise — enter lot number or scan bottle QR code |
| Ritual Essential for Women | `coa_not_per_lot` | Real "Certificate of Traceability" with per-lot heavy-metal/microbe testing claims, but unclear if searchable by an individual bottle's lot number — not claiming Tier 4 without that confirmation |
| Garden of Life Vitamin Code | `claimed_no_public_coa` | CoAs are public for their CBD product line specifically; "results for other products are not typically displayed publicly" |
| Nature's Bounty Fish Oil | `claimed_no_public_coa` | Explicitly confirmed: "no broad public U.S. batch-level COA portal," shoppers cannot verify lots numerically |
| Kirkland Signature D3 | `claimed_no_public_coa` | USP claim well-supported brand-wide; no public per-lot tool found |
| FGO Ashwagandha | `no_testing_claimed` | No testing claim found at all — only organic/Non-GMO certifications, consistent with this brand's overall opacity |
| Spring Valley Turmeric | `claimed_no_public_coa` | Supplier CoAs + finished-product third-party testing claimed, no public lookup tool found |
| Cellucor C4 Original | `claimed_no_public_coa` | General Nutrabolt testing claims exist but the clearest citation ties to a new India manufacturing announcement, not clearly this exact product |

Only Nordic Naturals qualifies for Tier 4 — a real, meaningful result, not an assumption that "big
brand = best tier."
