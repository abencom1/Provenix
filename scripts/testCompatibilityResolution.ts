#!/usr/bin/env node
/**
 * Fixture tests for resolveCompatibility (Build Prompt 3.4). No database
 * needed -- the resolver is a pure function (see its own header comment),
 * so these are plain in-memory assertions, unlike scripts/test*.ts for
 * 3.1/3.2/3.3 which all needed a live Supabase connection.
 *
 * Usage: npx tsx scripts/testCompatibilityResolution.ts
 */
import { resolveCompatibility } from "../src/lib/compatibility/resolveCompatibility";

let failures = 0;
function assertEqual(actual: unknown, expected: unknown, message: string) {
  if (JSON.stringify(actual) === JSON.stringify(expected)) {
    console.log(`PASS: ${message}`);
  } else {
    failures += 1;
    console.error(
      `FAIL: ${message}\n  expected: ${JSON.stringify(expected)}\n  actual:   ${JSON.stringify(actual)}`,
    );
  }
}

// Halal user, product with a porcine-derived excipient -> one flag, phrased
// like the spec's own example ("Contains porcine gelatin — conflicts with
// your halal preference.").
{
  const flags = resolveCompatibility({
    userPractices: ["halal"],
    productAttributes: [{ excipientName: "Gelatin (porcine)", attribute: "porcine" }],
  });
  assertEqual(flags.length, 1, "halal + porcine excipient produces one flag");
  assertEqual(
    flags[0]?.message,
    "Contains Gelatin (porcine) — conflicts with your halal preference.",
    "flag message matches the spec's example phrasing",
  );
}

// Vegan is flagged by dairy; gluten_free is not.
{
  const productAttributes = [{ excipientName: "Whey protein", attribute: "dairy" as const }];
  assertEqual(
    resolveCompatibility({ userPractices: ["vegan"], productAttributes }).length,
    1,
    "vegan is flagged by a dairy excipient",
  );
  assertEqual(
    resolveCompatibility({ userPractices: ["gluten_free"], productAttributes }).length,
    0,
    "gluten_free is NOT flagged by a dairy excipient",
  );
}

// Vegetarian allows dairy, rejects fish -- the lacto-vegetarian distinction
// from vegan.
{
  const flags = resolveCompatibility({
    userPractices: ["vegetarian"],
    productAttributes: [
      { excipientName: "Lactose", attribute: "dairy" },
      { excipientName: "Fish oil coating", attribute: "fish" },
    ],
  });
  assertEqual(flags.length, 1, "vegetarian is flagged by fish but not dairy");
  assertEqual(flags[0]?.attribute, "fish", "the one vegetarian flag is the fish excipient");
}

// carnivore has no mapped conflicts by design -- confirm it stays that way,
// not silently pick up a rule nobody signed off on.
{
  const flags = resolveCompatibility({
    userPractices: ["carnivore"],
    productAttributes: [{ excipientName: "Vegetable cellulose capsule", attribute: "plant_only" }],
  });
  assertEqual(flags.length, 0, "carnivore has no attribute conflicts defined yet (needs Aaron's input)");
}

// No user practices -> no flags, regardless of product.
{
  const flags = resolveCompatibility({
    userPractices: [],
    productAttributes: [{ excipientName: "Gelatin (porcine)", attribute: "porcine" }],
  });
  assertEqual(flags.length, 0, "no user practices produces no flags");
}

// plant_only never appears in any conflict list -- a vegan should never be
// flagged by a plant-derived excipient.
{
  const flags = resolveCompatibility({
    userPractices: ["vegan"],
    productAttributes: [{ excipientName: "Vegetable cellulose capsule", attribute: "plant_only" }],
  });
  assertEqual(flags.length, 0, "plant_only attribute never conflicts with vegan");
}

if (failures > 0) {
  console.error(`\n${failures} check(s) failed.`);
  process.exit(1);
}
console.log("\nAll compatibility resolution checks passed.");
