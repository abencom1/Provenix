import type {
  CompatibilityFlag,
  CompatibilityResolutionInput,
  DietaryAttribute,
  DietaryPractice,
} from "./types";

// Ingredient-inference proxy, NOT a religious-law or certification
// determination. See §9.4 in provenix_excipient_personalization_spec_v0.5.md:
// certification icons (kosher/halal/vegan/etc.) are the strong, universal,
// certification-sourced claim; this is the weaker, personal,
// ingredient-inferred one, and needs to read that way wherever it's
// rendered (§11.2 — "based on your preferences" must be on screen).
//
// halal/kosher mappings below are deliberately conservative proxies, not
// full religious-law determinations. Neither accounts for slaughter method
// (kosher shechita, halal dhabihah), kosher's meat/dairy separation rule (a
// combinatorial check across a product's whole ingredient set, not a
// single-attribute lookup), or the genuinely contested scholarly question
// of whether alcohol-derived excipients (as opposed to alcohol as a
// beverage ingredient) break halal compliance. Flagging porcine-derived
// content is safe and uncontroversial for both; everything past that is a
// real judgment call this function deliberately does not make on its own.
//
// 'carnivore' has NO attribute mapping. A supplement's inactive ingredients
// being plant-derived isn't the kind of conflict the other five practices
// represent (an ethical/religious/compositional exclusion), and nothing
// here should invent one. Needs Aaron's input before this practice flags
// anything.
const PRACTICE_ATTRIBUTE_CONFLICTS: Record<DietaryPractice, DietaryAttribute[]> = {
  halal: ["porcine"],
  kosher: ["porcine"],
  vegan: ["porcine", "bovine", "fish", "insect_derived", "dairy"],
  vegetarian: ["porcine", "bovine", "fish", "insect_derived"],
  gluten_free: ["gluten_bearing"],
  carnivore: [],
};

// Pure function -- (user practices, product attributes) in, compatibility
// flags out. No DB access, no score input, no score output (§11, Build
// Prompt 3.4). Fetching userPractices from user_dietary_practices and
// productAttributes from product_excipients/dietary_attributes/excipients is
// the caller's job, same separation as buildScoringInput vs. scoreProductV1.
export function resolveCompatibility(input: CompatibilityResolutionInput): CompatibilityFlag[] {
  const flags: CompatibilityFlag[] = [];

  for (const practice of input.userPractices) {
    const conflictingAttributes = PRACTICE_ATTRIBUTE_CONFLICTS[practice];
    for (const productAttribute of input.productAttributes) {
      if (conflictingAttributes.includes(productAttribute.attribute)) {
        flags.push({
          practice,
          excipientName: productAttribute.excipientName,
          attribute: productAttribute.attribute,
          message: `Contains ${productAttribute.excipientName} — conflicts with your ${practiceLabel(practice)} preference.`,
        });
      }
    }
  }

  return flags;
}

function practiceLabel(practice: DietaryPractice): string {
  return practice.replace("_", "-");
}
