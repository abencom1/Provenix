import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import type { ManufacturerAttributionDetail } from '@/lib/product/types';

import { ConfidenceBadge } from './confidence-badge';
import { VerifiedStamp } from './verified-stamp';

// Leads every product screen, above the Trust Score — the manufacturer
// reveal is the thing no label discloses and no competitor shows. See
// project_provenix_brand_direction's shared non-negotiable #1.
export function ManufacturerRevealCard({
  attribution,
}: {
  attribution: ManufacturerAttributionDetail;
}) {
  const theme = useTheme();
  const primary = attribution.facilities.find((f) => f.isPrimary);
  const isUnresolved = attribution.facilities.length === 0;
  const isAggregate = !isUnresolved && !primary;

  return (
    <ThemedView type="backgroundElement" style={[styles.card, { borderColor: theme.border }]}>
      <View style={[styles.accentBar, { backgroundColor: isUnresolved ? theme.textMuted : theme.primary }]} />
      <View style={styles.content}>
        <ThemedText type="small" themeColor="textMuted" style={styles.label}>
          MANUFACTURED BY
        </ThemedText>

        {isUnresolved ? (
          <>
            <ThemedText type="subtitle" style={styles.unresolvedTitle}>
              Not yet resolved
            </ThemedText>
            <ThemedText type="small" themeColor="textSecondary">
              We haven&apos;t confirmed who made this product yet. This is shown as a real signal,
              not hidden — resolution work is in progress.
            </ThemedText>
          </>
        ) : primary ? (
          <>
            <ThemedText type="subtitle">{primary.name}</ThemedText>
            {primary.address && (
              <ThemedText themeColor="textSecondary" style={styles.address}>
                {primary.address}
              </ThemedText>
            )}
          </>
        ) : (
          <>
            <ThemedText type="subtitle">{attribution.facilities[0].name}</ThemedText>
            <ThemedText themeColor="textSecondary" style={styles.address}>
              One of {attribution.facilities.length} known facilities — the specific plant that
              made this product isn&apos;t pinned down, so this reflects the manufacturer&apos;s
              record across all {attribution.facilities.length}.
            </ThemedText>
          </>
        )}

        <View style={styles.metaRow}>
          <ConfidenceBadge confidence={attribution.confidence} />
          <VerifiedStamp date={isUnresolved ? null : attribution.verifiedAt} />
        </View>

        {isAggregate && (
          <View style={styles.facilityList}>
            {attribution.facilities.map((f) => (
              <ThemedText key={f.id} type="small" themeColor="textSecondary">
                · {f.name}
                {f.address ? ` — ${f.address}` : ''}
              </ThemedText>
            ))}
          </View>
        )}

        {attribution.sourceDetail && !isUnresolved && (
          <ThemedText type="small" themeColor="textMuted" style={styles.source}>
            Source: {attribution.sourceDetail}
          </ThemedText>
        )}
      </View>
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    borderWidth: 1,
    borderRadius: Spacing.three,
    overflow: 'hidden',
  },
  accentBar: {
    width: 4,
  },
  content: {
    flex: 1,
    padding: Spacing.four,
    gap: Spacing.two,
  },
  label: {
    letterSpacing: 1,
  },
  unresolvedTitle: {
    fontSize: 22,
  },
  address: {
    marginTop: -Spacing.one,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: Spacing.one,
  },
  facilityList: {
    gap: Spacing.half,
    marginTop: Spacing.one,
  },
  source: {
    marginTop: Spacing.one,
  },
});
