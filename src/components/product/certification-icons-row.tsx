import { StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import type { CertificationIcon } from '@/lib/product/types';

// §9.4: universal, no sign-in required, and an icon only ever means a real
// third-party certification was found. An outlined/absent chip is NOT a
// negative claim — never styled as a failure state.
export function CertificationIconsRow({ certifications }: { certifications: CertificationIcon[] }) {
  const theme = useTheme();

  return (
    <View style={styles.container}>
      <View style={styles.row}>
        {certifications.map((cert) => (
          <View
            key={cert.category}
            style={[
              styles.chip,
              cert.present
                ? { backgroundColor: theme.primarySubtle, borderColor: theme.primary }
                : { borderColor: theme.border, borderStyle: 'dashed' },
            ]}>
            {cert.present && (
              <ThemedText type="smallBold" style={{ color: theme.primary }}>
                ✓
              </ThemedText>
            )}
            <ThemedText
              type="smallBold"
              style={{ color: cert.present ? theme.primary : theme.textMuted }}>
              {cert.label}
            </ThemedText>
          </View>
        ))}
      </View>
      <ThemedText type="small" themeColor="textMuted">
        Outlined = no certification on file, not a failing grade.
      </ThemedText>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    gap: Spacing.two,
  },
  row: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: Spacing.two,
  },
  chip: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.half,
    paddingVertical: Spacing.one,
    paddingHorizontal: Spacing.three,
    borderRadius: Spacing.five,
    borderWidth: 1,
  },
});
