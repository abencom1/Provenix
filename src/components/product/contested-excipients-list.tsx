import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';

// §9.3: listed, and nothing else. No icon, no color, no warning styling, no
// separate card. Styling that implies concern is the same failure as
// writing a warning — this renders as plain text, deliberately.
export function ContestedExcipientsList({ names }: { names: string[] }) {
  if (names.length === 0) return null;

  return (
    <View style={styles.container}>
      <ThemedText type="small" themeColor="textSecondary" style={styles.line}>
        {names.join(' · ')}
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: Spacing.half,
  },
  line: {
    lineHeight: 22,
  },
});
