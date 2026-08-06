import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import type { CompatibilityFlagDisplay } from '@/lib/product/types';

// §9.2/§11: personal, ingredient-inferred, never scored. Deliberately never
// styled like a CertificationIconsRow chip — this is the weaker, unverified
// claim, and needs to read that way. "Based on your preferences" stays on
// screen, not just implied.
export function CompatibilityFlag({ flag }: { flag: CompatibilityFlagDisplay }) {
  const theme = useTheme();

  return (
    <View style={styles.row}>
      <View style={[styles.dot, { backgroundColor: theme.textMuted }]} />
      <View style={styles.textCol}>
        <ThemedText type="small" themeColor="textMuted" style={styles.eyebrow}>
          BASED ON YOUR PREFERENCES
        </ThemedText>
        <ThemedText type="small">{flag.message}</ThemedText>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: 'row',
    gap: Spacing.two,
  },
  dot: {
    width: 5,
    height: 5,
    borderRadius: 3,
    marginTop: 7,
  },
  textCol: {
    flex: 1,
    gap: Spacing.half,
  },
  eyebrow: {
    letterSpacing: 0.5,
  },
});
