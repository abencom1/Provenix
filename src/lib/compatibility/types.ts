export type DietaryPractice =
  | "halal"
  | "kosher"
  | "vegan"
  | "vegetarian"
  | "gluten_free"
  | "carnivore";

export type DietaryAttribute =
  | "porcine"
  | "bovine"
  | "fish"
  | "insect_derived"
  | "dairy"
  | "gluten_bearing"
  | "alcohol_derived"
  | "plant_only";

export type ProductExcipientAttribute = {
  excipientName: string;
  attribute: DietaryAttribute;
};

export type CompatibilityFlag = {
  practice: DietaryPractice;
  excipientName: string;
  attribute: DietaryAttribute;
  message: string;
};

export type CompatibilityResolutionInput = {
  userPractices: DietaryPractice[];
  productAttributes: ProductExcipientAttribute[];
};
