import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { ThemedView } from '@/components/themed-view';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { formatVerifiedDate } from '@/lib/product/format';
import type { CorrectionLogEntry } from '@/lib/product/types';

// Visible on the product page itself, not buried in T&Cs — a product that
// has never needed a correction and one that's never been checked should
// not look the same.
export function CorrectionLogCard({ entries }: { entries: CorrectionLogEntry[] }) {
  const theme = useTheme();

  return (
    <ThemedView type="backgroundElement" style={[styles.card, { borderColor: theme.border }]}>
      <ThemedText type="smallBold">Correction log</ThemedText>
      {entries.length === 0 ? (
        <ThemedText type="small" themeColor="textSecondary">
          No corrections recorded for this product.
        </ThemedText>
      ) : (
        <View style={styles.list}>
          {entries.map((entry, i) => (
            <View key={i} style={styles.entry}>
              <ThemedText type="small">{entry.whatChanged}</ThemedText>
              <ThemedText type="small" themeColor="textSecondary">
                {entry.reason}
              </ThemedText>
              <ThemedText type="small" themeColor="textMuted">
                {formatVerifiedDate(entry.correctedAt)}
              </ThemedText>
            </View>
          ))}
        </View>
      )}
    </ThemedView>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: Spacing.three,
    padding: Spacing.four,
    gap: Spacing.two,
  },
  list: {
    gap: Spacing.three,
  },
  entry: {
    gap: Spacing.half,
  },
});
