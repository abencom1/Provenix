import { ThemedText } from '@/components/themed-text';
import { formatVerifiedDate } from '@/lib/product/format';

export function VerifiedStamp({ date }: { date: string | null }) {
  return (
    <ThemedText type="small" themeColor="textMuted">
      {date ? `Verified ${formatVerifiedDate(date)}` : 'Not yet verified'}
    </ThemedText>
  );
}
