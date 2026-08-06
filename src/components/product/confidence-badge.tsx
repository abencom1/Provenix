import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';

type Confidence = 'high' | 'moderate' | 'low' | null;

const LABEL: Record<'high' | 'moderate' | 'low' | 'unresolved', string> = {
  high: 'High confidence',
  moderate: 'Moderate confidence',
  low: 'Low confidence',
  unresolved: 'Unresolved',
};

export function ConfidenceBadge({ confidence }: { confidence: Confidence }) {
  const theme = useTheme();
  const key = confidence ?? 'unresolved';
  const color =
    key === 'high' ? theme.success : key === 'moderate' ? theme.warning : theme.danger;

  return (
    <View style={[styles.badge, { backgroundColor: color + '1F', borderColor: color }]}>
      <View style={[styles.dot, { backgroundColor: color }]} />
      <ThemedText type="smallBold" style={{ color }}>
        {LABEL[key]}
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  badge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.one,
    alignSelf: 'flex-start',
    borderWidth: 1,
    borderRadius: Spacing.five,
    paddingVertical: Spacing.half,
    paddingHorizontal: Spacing.two,
  },
  dot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
});
