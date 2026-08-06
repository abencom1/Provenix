import type { ReactNode } from 'react';
import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { HELPING_THRESHOLD } from '@/lib/product/subscoreMeta';
import type { SubscoreDetail } from '@/lib/product/types';

import { SubscoreRow } from './subscore-row';

// Credit Karma-style grouping: what's helping, what's hurting, what's
// missing — rather than a flat list of bars a reader has to parse
// individually. regulatory_compliance is excluded here on purpose — it gets
// its own dedicated section (RegulatoryComplianceSection) with the
// facility-record/ingredient-flags split Build Prompt 3.5 requires, not a
// generic bar.
export function SubscoreBreakdown({ subscores }: { subscores: SubscoreDetail[] }) {
  const rest = subscores.filter((s) => s.type !== 'regulatory_compliance');
  const helping = rest.filter((s) => s.value !== null && s.value >= HELPING_THRESHOLD);
  const hurting = rest.filter((s) => s.value !== null && s.value < HELPING_THRESHOLD);
  const missing = rest.filter((s) => s.value === null);

  return (
    <View style={styles.container}>
      {helping.length > 0 && (
        <Section title="What's helping">
          {helping.map((s) => (
            <SubscoreRow key={s.type} subscore={s} />
          ))}
        </Section>
      )}
      {hurting.length > 0 && (
        <Section title="What's hurting">
          {hurting.map((s) => (
            <SubscoreRow key={s.type} subscore={s} />
          ))}
        </Section>
      )}
      {missing.length > 0 && (
        <Section title="What would move the needle">
          {missing.map((s) => (
            <SubscoreRow key={s.type} subscore={s} />
          ))}
        </Section>
      )}
    </View>
  );
}

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <View style={styles.section}>
      <ThemedText type="small" themeColor="textMuted" style={styles.sectionTitle}>
        {title.toUpperCase()}
      </ThemedText>
      <View style={styles.sectionBody}>{children}</View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: Spacing.four,
  },
  section: {
    gap: Spacing.three,
  },
  sectionTitle: {
    letterSpacing: 1,
  },
  sectionBody: {
    gap: Spacing.four,
  },
});
