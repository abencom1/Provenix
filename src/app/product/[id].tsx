import { router, useLocalSearchParams } from 'expo-router';
import type { ReactNode } from 'react';
import { Pressable, ScrollView, StyleSheet, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { CertificationIconsRow } from '@/components/product/certification-icons-row';
import { CompatibilityFlag } from '@/components/product/compatibility-flag';
import { ContestedExcipientsList } from '@/components/product/contested-excipients-list';
import { CorrectionLogCard } from '@/components/product/correction-log-card';
import { ManufacturerRevealCard } from '@/components/product/manufacturer-reveal-card';
import { RegulatoryComplianceSection } from '@/components/product/regulatory-compliance-section';
import { SubscoreBreakdown } from '@/components/product/subscore-breakdown';
import { TrustScoreHero } from '@/components/product/trust-score-hero';
import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { MaxContentWidth, Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { mockHydroxycut } from '@/lib/product/mockHydroxycut';

// `id` isn't used to fetch yet — there's no client-side Supabase anon key
// configured, so this always renders the one mocked product (see
// mockHydroxycut.ts). Swapping in a real fetch by `id` is a data-layer
// change only; every component below already reads from ProductDetail.
export default function ProductScreen() {
  useLocalSearchParams<{ id: string }>();
  const product = mockHydroxycut;
  const theme = useTheme();

  const regulatorySubscore = product.subscoreDetails.find(
    (s) => s.type === 'regulatory_compliance',
  );

  return (
    <ThemedView style={styles.screen}>
      <SafeAreaView style={styles.safeArea} edges={['top', 'bottom']}>
        <ScrollView contentContainerStyle={styles.scrollContent}>
          <Pressable onPress={() => router.back()} hitSlop={12} style={styles.backButton}>
            <ThemedText type="link" themeColor="textSecondary">
              ‹ Back
            </ThemedText>
          </Pressable>

          <ThemedText type="small" themeColor="textMuted">
            {product.brandName}
          </ThemedText>
          <ThemedText type="subtitle" style={styles.productName}>
            {product.name}
          </ThemedText>

          <ManufacturerRevealCard attribution={product.attribution} />

          <TrustScoreHero
            trustScore={product.trustScore}
            verifiedAt={product.attribution.verifiedAt}
          />

          <Section title="Regulatory & compliance">
            <RegulatoryComplianceSection
              value={regulatorySubscore?.value ?? null}
              verifiedAt={regulatorySubscore?.verifiedAt ?? product.attribution.verifiedAt}
              facilityRecords={product.facilityRecords}
              ingredientFlags={product.ingredientRegulatoryFlags}
            />
          </Section>

          <SubscoreBreakdown subscores={product.subscoreDetails} />

          {product.adverseEventCount !== null && (
            <ThemedText type="small" themeColor="textMuted" style={styles.disclaimer}>
              Adverse event counts are raw report totals from FDA&apos;s public system — not
              verified causal reports and not a rate against units sold. Shown for context only,
              never as a primary driver of the Trust Score.
            </ThemedText>
          )}

          <Section title="Certifications">
            <CertificationIconsRow certifications={product.certifications} />
          </Section>

          {product.compatibilityFlags.length > 0 && (
            <View style={styles.compatList}>
              {product.compatibilityFlags.map((flag, i) => (
                <CompatibilityFlag key={i} flag={flag} />
              ))}
            </View>
          )}

          <Section title="Other ingredients">
            <ContestedExcipientsList names={product.contestedExcipients} />
          </Section>

          <CorrectionLogCard entries={product.correctionLog} />

          {product.excipientDataIsIllustrative && (
            <ThemedView
              type="backgroundElement"
              style={[styles.illustrativeNote, { borderColor: theme.border }]}>
              <ThemedText type="small" themeColor="textMuted">
                Ingredient regulatory flags, certifications, and compatibility flags above use
                illustrative example data — no product in the database has real excipient rows
                seeded yet. Manufacturer, Trust Score, and facility/manufacturer regulatory record
                are real.
              </ThemedText>
            </ThemedView>
          )}
        </ScrollView>
      </SafeAreaView>
    </ThemedView>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <View style={styles.section}>
      <ThemedText type="smallBold" style={styles.sectionLabel}>
        {title}
      </ThemedText>
      {children}
    </View>
  );
}

const styles = StyleSheet.create({
  screen: {
    flex: 1,
  },
  safeArea: {
    flex: 1,
    alignItems: 'center',
  },
  scrollContent: {
    width: '100%',
    maxWidth: MaxContentWidth,
    paddingHorizontal: Spacing.four,
    paddingBottom: Spacing.six,
    gap: Spacing.five,
  },
  backButton: {
    alignSelf: 'flex-start',
    paddingVertical: Spacing.two,
  },
  productName: {
    fontSize: 24,
    lineHeight: 30,
  },
  section: {
    gap: Spacing.three,
  },
  sectionLabel: {
    fontSize: 15,
  },
  compatList: {
    gap: Spacing.three,
  },
  disclaimer: {
    marginTop: -Spacing.two,
  },
  illustrativeNote: {
    borderWidth: 1,
    borderRadius: Spacing.three,
    padding: Spacing.three,
  },
});
