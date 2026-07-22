const FDA_DASHBOARD_BASE_URL = "https://api-datadashboard.fda.gov/v1";

type FdaDashboardQuery = {
  filters?: Record<string, unknown>;
  columns?: string[];
  start?: number;
  rows?: number;
  sort?: string;
  sortorder?: "ASC" | "DESC";
  returntotalcount?: boolean;
};

type FdaDashboardResponse<T> = {
  resultcount: number;
  totalcount?: number;
  data: T[];
};

// Deliberately NOT EXPO_PUBLIC_-prefixed: this credential is for server-side
// ingestion (GitHub Actions cron), never the client bundle. Unprefixed vars are
// simply undefined inside the Expo app, so this module only works run from Node.
async function queryDashboard<T>(
  endpoint: string,
  query: FdaDashboardQuery = {},
): Promise<FdaDashboardResponse<T>> {
  const user = process.env.FDA_DASHBOARD_AUTH_USER;
  const key = process.env.FDA_DASHBOARD_AUTH_KEY;
  if (!user || !key) {
    throw new Error("FDA_DASHBOARD_AUTH_USER / FDA_DASHBOARD_AUTH_KEY are not set");
  }

  const res = await fetch(`${FDA_DASHBOARD_BASE_URL}/${endpoint}`, {
    method: "POST",
    headers: {
      "Authorization-User": user,
      "Authorization-Key": key,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ start: 1, rows: 5000, returntotalcount: true, ...query }),
  });

  if (!res.ok) throw new Error(`FDA Data Dashboard request failed: ${res.status}`);
  return res.json();
}

// FEINumber is the join key across all four endpoints below — it ties a
// manufacturing facility to its full enforcement history.
export type InspectionClassification = {
  FEINumber: number;
  LegalName: string;
  Classification: string; // NAI / VAI / OAI
  [key: string]: unknown;
};

export function getInspectionsClassifications(query?: FdaDashboardQuery) {
  return queryDashboard<InspectionClassification>("inspections_classifications", query);
}

export type InspectionCitation = {
  FEINumber: number;
  [key: string]: unknown;
};

export function getInspectionsCitations(query?: FdaDashboardQuery) {
  return queryDashboard<InspectionCitation>("inspections_citations", query);
}

export type ComplianceAction = {
  FEINumber: number;
  [key: string]: unknown;
};

export function getComplianceActions(query?: FdaDashboardQuery) {
  return queryDashboard<ComplianceAction>("compliance_actions", query);
}

export type ImportRefusal = {
  FEINumber: number;
  [key: string]: unknown;
};

export function getImportRefusals(query?: FdaDashboardQuery) {
  return queryDashboard<ImportRefusal>("import_refusals", query);
}
