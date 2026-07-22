const OPENFDA_BASE_URL = "https://api.fda.gov";

type OpenFdaSearchParams = {
  search?: string;
  limit?: number;
  skip?: number;
};

type OpenFdaResponse<T> = {
  meta: {
    disclaimer: string;
    terms: string;
    license: string;
    last_updated: string;
    results: { skip: number; limit: number; total: number };
  };
  results: T[];
};

function buildUrl(path: string, params: OpenFdaSearchParams): string {
  const url = new URL(`${OPENFDA_BASE_URL}${path}`);
  const apiKey = process.env.EXPO_PUBLIC_OPENFDA_API_KEY;
  if (apiKey) url.searchParams.set("api_key", apiKey);
  if (params.search) url.searchParams.set("search", params.search);
  if (params.limit) url.searchParams.set("limit", String(params.limit));
  if (params.skip) url.searchParams.set("skip", String(params.skip));
  return url.toString();
}

export type FoodEnforcementReport = {
  recall_number: string;
  product_description: string;
  reason_for_recall: string;
  classification: string;
  status: string;
  distribution_pattern: string;
  recalling_firm: string;
  report_date: string;
  [key: string]: unknown;
};

export async function getFoodRecalls(
  params: OpenFdaSearchParams = {},
): Promise<OpenFdaResponse<FoodEnforcementReport>> {
  const res = await fetch(buildUrl("/food/enforcement.json", params));
  if (!res.ok) throw new Error(`openFDA recalls request failed: ${res.status}`);
  return res.json();
}

export type FoodAdverseEventReport = {
  report_number: string;
  date_created: string;
  products: unknown[];
  reactions: unknown[];
  [key: string]: unknown;
};

// FDA states these reports are unverified, and when one lists several products and
// several reactions, no single reaction can be attributed to a single product —
// callers must preserve that ambiguity rather than pairing them 1:1 in the UI.
export async function getFoodAdverseEvents(
  params: OpenFdaSearchParams = {},
): Promise<OpenFdaResponse<FoodAdverseEventReport>> {
  const res = await fetch(buildUrl("/food/event.json", params));
  if (!res.ok) throw new Error(`openFDA adverse events request failed: ${res.status}`);
  return res.json();
}
