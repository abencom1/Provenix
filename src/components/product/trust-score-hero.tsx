import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import type { TrustScoreResultV1 } from '@/lib/scoring/types';

import { VerifiedStamp } from './verified-stamp';

export function TrustScoreHero({
  trustScore,
  verifiedAt,
}: {
  trustScore: TrustScoreResultV1;
  verifiedAt: string;
}) {
  const theme = useTheme();

  if (!trustScore.isScorable) {
    return (
      <View style={styles.container}>
        <ThemedText type="title" style={[styles.scoreNumber, { color: theme.textMuted }]}>
          —
        </ThemedText>
        <ThemedText type="small" themeColor="textSecondary" style={styles.explanation}>
          {trustScore.explanation}
        </ThemedText>
      </View>
    );
  }

  const scoreColor =
    trustScore.overallScore! >= 70
      ? theme.success
      : trustScore.overallScore! >= 40
        ? theme.warning
        : theme.danger;

  return (
    <View style={styles.container}>
      <ThemedText type="title" style={[styles.scoreNumber, { color: scoreColor }]}>
        {trustScore.overallScore}
      </ThemedText>
      <ThemedText type="small" themeColor="textSecondary">
        Provenix Trust Score
      </ThemedText>
      <View style={styles.verifiedRow}>
        <VerifiedStamp date={verifiedAt} />
      </View>
      <ThemedText type="small" themeColor="textMuted" style={styles.explanation}>
        {trustScore.explanation}
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    gap: Spacing.half,
    paddingVertical: Spacing.four,
  },
  scoreNumber: {
    fontSize: 72,
    lineHeight: 76,
  },
  verifiedRow: {
    marginTop: Spacing.one,
  },
  explanation: {
    textAlign: 'center',
    marginTop: Spacing.two,
    maxWidth: 320,
  },
});
