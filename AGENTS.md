# Expo HAS CHANGED

Read the exact versioned docs at https://docs.expo.dev/versions/v56.0.0/ before writing any code.

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

Full spec: `provenix_excipient_personalization_spec_v0.5.md`.
