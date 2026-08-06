import { useState, type ReactNode } from 'react';
import { Pressable, StyleSheet, View } from 'react-native';

import { ThemedText } from '@/components/themed-text';
import { Spacing } from '@/constants/theme';
import { useTheme } from '@/hooks/use-theme';
import { formatVerifiedDate } from '@/lib/product/format';
import type { IngredientRegulatoryFlag, RegulatoryRecordSummary } from '@/lib/product/types';

// Build Prompt 3.5: facility/manufacturer record and ingredient regulatory
// flags feed ONE subscore number but render as two distinct, collapsible
// groups — never blended into an undifferentiated list. Both collapsed by
// default except a group with an active flag, which opens automatically so
// the thing that actually needs attention isn't hidden behind a tap.
export function RegulatoryComplianceSection({
  value,
  verifiedAt,
  facilityRecords,
  ingredientFlags,
}: {
  value: number | null;
  verifiedAt: string;
  facilityRecords: RegulatoryRecordSummary[];
  ingredientFlags: IngredientRegulatoryFlag[];
}) {
  const theme = useTheme();
  const hasActiveIngredientFlag = ingredientFlags.some((f) => f.status === 'active');

  return (
    <View style={[styles.card, { borderColor: theme.border }]}>
      <View style={styles.scoreRow}>
        <ThemedText type="title" style={[styles.scoreNum, { color: theme.primary }]}>
          {value ?? '—'}
        </ThemedText>
        <ThemedText type="small" themeColor="textSecondary">
          Verified {formatVerifiedDate(verifiedAt)}
        </ThemedText>
      </View>

      <DisclosureGroup
        title="Facility & manufacturer record"
        summary={`${facilityRecords.length} record${facilityRecords.length === 1 ? '' : 's'}`}
        defaultOpen={false}
      >
        <View style={styles.groupBody}>
          {facilityRecords.map((record, i) => (
            <View key={`${record.label}-${i}`} style={styles.row}>
              <View style={styles.rowTop}>
                <ThemedText type="smallBold">{record.label}</ThemedText>
              </View>
              <ThemedText type="small" themeColor="textSecondary" style={styles.rowDetail}>
                {record.detail}
              </ThemedText>
            </View>
          ))}
        </View>
      </DisclosureGroup>

      <DisclosureGroup
        title="Ingredient regulatory flags"
        summary={`${ingredientFlags.length} active`}
        flagged={hasActiveIngredientFlag}
        defaultOpen={hasActiveIngredientFlag}
      >
        <View style={styles.groupBody}>
          {ingredientFlags.length === 0 ? (
            <ThemedText type="small" themeColor="textSecondary">
              No Tier-I regulatory actions on file for this product&apos;s disclosed excipients.
            </ThemedText>
          ) : (
            ingredientFlags.map((flag, i) => (
              <View key={`${flag.excipientName}-${i}`} style={styles.row}>
                <View style={styles.rowTop}>
                  <ThemedText type="smallBold">
                    {flag.excipientName} — {flag.regulator}
                  </ThemedText>
                  <ThemedText type="small" themeColor="textMuted">
                    {formatVerifiedDate(flag.effectiveDate)}
                  </ThemedText>
                </View>
                <ThemedText type="small" themeColor="textSecondary" style={styles.rowDetail}>
                  {flag.detail}
                  {flag.jurisdiction ? ` · ${flag.jurisdiction} jurisdiction` : ''}
                </ThemedText>

                {flag.otherSources.length > 0 && (
                  <View style={[styles.noteBlock, { borderColor: theme.border }]}>
                    {flag.otherSources.map((source, j) => (
                      <ThemedText key={j} type="small" themeColor="textSecondary" style={styles.noteLine}>
                        <ThemedText type="smallBold" themeColor="textSecondary">
                          {source.source}
                        </ThemedText>{' '}
                        — {source.statement}
                      </ThemedText>
                    ))}
                  </View>
                )}
              </View>
            ))
          )}
        </View>
      </DisclosureGroup>
    </View>
  );
}

function DisclosureGroup({
  title,
  summary,
  flagged = false,
  defaultOpen,
  children,
}: {
  title: string;
  summary: string;
  flagged?: boolean;
  defaultOpen: boolean;
  children: ReactNode;
}) {
  const theme = useTheme();
  const [open, setOpen] = useState(defaultOpen);

  return (
    <View style={[styles.group, { borderTopColor: theme.border }]}>
      <Pressable onPress={() => setOpen((v) => !v)} style={styles.summaryRow}>
        <View style={styles.summaryLeft}>
          {flagged && <View style={[styles.flagDot, { backgroundColor: theme.warning }]} />}
          <ThemedText type="smallBold">{title}</ThemedText>
        </View>
        <View style={styles.summaryLeft}>
          <ThemedText type="small" themeColor="textMuted">
            {summary}
          </ThemedText>
          <ThemedText type="small" themeColor="textMuted" style={open && styles.chevronOpen}>
            ›
          </ThemedText>
        </View>
      </Pressable>
      {open && children}
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderWidth: 1,
    borderRadius: Spacing.four,
    padding: Spacing.four,
  },
  scoreRow: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: Spacing.two,
    paddingBottom: Spacing.two,
  },
  scoreNum: {
    fontSize: 34,
    lineHeight: 36,
  },
  group: {
    borderTopWidth: 1,
  },
  summaryRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: Spacing.three,
  },
  summaryLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: Spacing.one,
  },
  flagDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  chevronOpen: {
    transform: [{ rotate: '90deg' }],
  },
  groupBody: {
    gap: Spacing.three,
    paddingBottom: Spacing.four,
  },
  row: {
    gap: Spacing.half,
  },
  rowTop: {
    flexDirection: 'row',
    alignItems: 'baseline',
    justifyContent: 'space-between',
    gap: Spacing.two,
  },
  rowDetail: {
    lineHeight: 18,
  },
  noteBlock: {
    marginTop: Spacing.half,
    paddingLeft: Spacing.two,
    borderLeftWidth: 2,
    gap: Spacing.half,
  },
  noteLine: {
    lineHeight: 18,
  },
});
