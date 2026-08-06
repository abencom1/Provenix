import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { formatVerifiedDate } from '@/lib/product/format';
import { SUBSCORE_LABELS } from '@/lib/product/subscoreMeta';
import type { SubscoreDetail } from '@/lib/product/types';

export function SubscoreRow({ subscore }: { subscore: SubscoreDetail }) {
  const theme = useTheme();
  const value = subscore.value;
  const barColor =
    value === null
      ? theme.border
      : value >= 70
        ? theme.success
        : value >= 40
          ? theme.warning
          : theme.danger;

  return (
    <View style={styles.row}>
      <View style={styles.headerLine}>
        <ThemedText type="smallBold">{SUBSCORE_LABELS[subscore.type]}</ThemedText>
        <ThemedText type="smallBold" style={{ color: value === null ? theme.textMuted : barColor }}>
          {value === null ? 'No data' : value}
        </ThemedText>
      </View>

      <View style={[styles.track, { backgroundColor: theme.border }]}>
        {value !== null && (
          <View style={[styles.fill, { width: `${value}%`, backgroundColor: barColor }]} />
        )}
      </View>

      <ThemedText type="small" themeColor="textSecondary" style={styles.headline}>
        {subscore.headline}
      </ThemedText>
      {subscore.verifiedAt && (
        <ThemedText type="small" themeColor="textMuted">
          Verified {formatVerifiedDate(subscore.verifiedAt)}
        </ThemedText>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    gap: Spacing.one,
  },
  headerLine: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  track: {
    height: 6,
    borderRadius: 3,
    overflow: 'hidden',
  },
  fill: {
    height: '100%',
    borderRadius: 3,
  },
  headline: {
    marginTop: Spacing.half,
  },
});
