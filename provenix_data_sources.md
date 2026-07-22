# Provenix — Data Source Map

Every public data source that feeds the schema, sorted by **how hard it is to get**, and mapped
to the table it populates. Verify all licensing and terms yourself before shipping — terms change,
and this is the part with legal consequences.

---

## The most important thing on this page

**Do not build ingestion pipelines for 12 seed SKUs.** Hand-enter them.

Pipelines are the right answer at 500+ products. At 12, writing a scraper costs more time than
typing the data and teaches you less about whether your Trust Score actually works. Build the
pipeline when manual entry genuinely hurts — that pain is the signal, and it arrives later than
you think. What follows is a map for when you get there, not a build list for this month.

---

## Tier 1 — Real JSON APIs, free, start here

### openFDA (api.fda.gov)
Free key at open.fda.gov/apis/authentication. Passed as the `api_key` query parameter.
Limits with a key: 240 requests/minute, 120,000/day.

| Endpoint | What it gives | Populates |
|---|---|---|
| `/food/enforcement.json` | Food & supplement recall enforcement reports, from FDA's Recall Enterprise System. 2004–present, updated weekly. | `recalls` |
| `/food/event.json` | CAERS — adverse event and complaint reports for foods, supplements, and cosmetics. | `adverse_event_counts` |

Bulk downloads of both are available as zipped JSON if you'd rather load a snapshot than page
through the API.

**Required handling for CAERS:** FDA is explicit that these reports aren't validated or verified,
and that no causal relationship between product and reaction can be drawn. When a report lists
several products and several reactions, you cannot attribute a given reaction to a given product.
Your §12.2 display rule isn't optional politeness — it's the condition of using the data honestly.

### NIH Dietary Supplement Label Database (DSLD)
API guide: dsld.od.nih.gov/api-guide · API: dsldapi.od.nih.gov

200,000+ current and historical US supplement labels, sourced from national surveys and voluntary
manufacturer submissions. Searchable by brand, product name, supplement form, and claim type.
**Published CC0** — public domain, no share-alike obligation.

Populates: `products.ingredient_list`, and potentially your whole identity layer.

**Worth a real decision:** your spec's identity layer is Open Food Facts, which is ODbL —
share-alike, hence the isolated `identity` schema. DSLD is CC0, supplement-native, and includes
full ingredient and claims data. It may be the better spine, with Open Food Facts as barcode
fallback (DSLD is label-indexed, not necessarily GTIN-complete — verify barcode coverage before
switching).

---

## Tier 2 — Real API, but requires credentials

### FDA Data Dashboard API (datadashboard.fda.gov/oii/api)
REST API over FDA's compliance and enforcement datasets. Refreshed weekly (Mondays; imports
Thursdays). **Request credentials through the OII Unified Logon application — do this early,
approval takes time.**

| Endpoint | What it gives | Populates |
|---|---|---|
| Compliance Actions | Warning letters, seizures, injunctions | `warning_letters` |
| Inspections Classifications | Facility inspection outcomes: NAI / VAI / OAI | new — see below |
| Inspections Citations | Observation-level inspection findings | `form_483s` |
| Import Refusals | Shipments refused entry | see import alert note |

**`FEINumber` is a queryable field.** This is the single most useful fact in this document — FEI
is the join key between a facility and its entire enforcement history, and facility resolution is
your hardest problem.

**Schema addition to consider:** inspection classification (NAI/VAI/OAI) is a cleaner compliance
signal than warning letters alone — most facilities never get a warning letter, but many get
inspected. A `facility_inspections` table would give your regulatory_compliance subscore something
to work with on facilities that are simply clean. Worth adding.

**Caveats FDA states directly:** only finalized actions appear; some records are withheld until
related enforcement concludes; not all inspections are included (state-conducted, pre-approval,
and pending-action inspections are excluded). Absence of a record is not evidence of compliance —
and your UI must not imply it is.

**This weakens the case for licensing Redica/FDAzilla at MVP.** The commercial value there is
full 483 text and faster posting; the Citations endpoint may cover enough of your scoring need.
Evaluate before spending — one of your six open decisions may resolve itself.

---

## Tier 3 — Downloads, no API

### FDA Warning Letters (fda.gov searchable database)
Searchable by company, date, issuing office, subject, and whether a response or closeout letter
was posted. **The results page has an Export Excel button** — for a curated SKU list this beats
writing a scraper.

### data.gov warning letters dataset
catalog.data.gov carries a warning letters dataset with a query tool and download. Check the
"last updated" date before relying on it — dataset freshness on data.gov varies.

---

## Tier 4 — Scraping or manual only

### Import Alerts — accessdata.fda.gov (CMS_IA)
The DWPE "red list" system. HTML only, no official API.

**Do not confuse import alerts with import refusals.** A refusal is one rejected shipment; an
alert is a standing detention-without-physical-examination order. Your schema separates
`facility_specific` from `category_level` scope for exactly this reason — a firm named on an alert
is a much stronger signal than a firm shipping in a category that happens to be alerted.
Collapsing them is an accuracy failure that would make your scores wrong in a way users would
never see.

Populates: `import_alerts`

### NDI Notification log — fda.gov
Published list of new dietary ingredient notifications. Populates `ndi_flags`.
**Carry the context field every time:** absence of a notification is not itself a violation.

### NSF / USP / Informed Sport certification lookups
Manual lookups only — NSF's terms forbid scraping, which is why your schema defaults
`certifications.source` to `nsf_manual_lookup`. Verify on the certifier's own site and capture the
URL. Never trust a badge image on a brand's marketing page.

Populates: `certifications`

---

## Suggested sequence

1. **Now:** request FDA Data Dashboard credentials (slow, so start the clock)
2. **Now:** hand-enter your 3 pilot SKUs — no code
3. **After the score renders:** evaluate DSLD vs Open Food Facts for the identity layer
4. **At ~50 SKUs:** automate openFDA (easiest, two endpoints, well documented)
5. **At ~100 SKUs:** add Data Dashboard for warning letters + inspections
6. **At ~500 SKUs:** revisit import alert scraping and the Redica/FDAzilla question

---

## Non-negotiables for every source

- Store `source` and `retrieved_at` on every row. Your schema already requires this.
- **Absence of a record never means compliance.** FDA withholds, delays, and excludes records by
  policy. Your UI must distinguish "no adverse findings" from "no data" — conflating them is the
  most likely way Provenix publishes something false about a real company.
- Re-read each source's terms before launch, not after.
