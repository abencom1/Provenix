/**
 * Below are the colors that are used in the app. The colors are defined in the light and dark mode.
 * There are many other ways to style your app. For example, [Nativewind](https://www.nativewind.dev/), [Tamagui](https://tamagui.dev/), [unistyles](https://reactnativeunistyles.vercel.app), etc.
 */

import '@/global.css';

import { Platform } from 'react-native';

// App UI brand direction: "D2 Clarity" (light spa-green) — app-wide as of
// 2026-08-06, matching the web landing page. See
// project_provenix_brand_direction memory. Tokens below are taken directly
// from provenix_landing.html's --canvas/--mist/--sage/--grove/--deep/--ink/
// --muted/--faint/--amber custom properties, not reinvented.
export const Colors = {
  light: {
    text: '#1A2E28',
    textSecondary: '#4A6B61',
    textMuted: '#8AADA6',
    background: '#F6FBF9',
    backgroundElement: '#EAF5F0',
    backgroundSelected: '#DCEEE6',
    border: '#C8DDD8',
    primary: '#1C7A5E',
    primaryText: '#FFFFFF',
    primarySubtle: '#EAF5F0',
    primarySubtleBorder: '#C8DDD8',
    success: '#1C7A5E',
    warning: '#D97706',
    danger: '#B54834',
  },
  dark: {
    text: '#EAF3EF',
    textSecondary: '#9DB8AE',
    textMuted: '#638075',
    background: '#0E1613',
    backgroundElement: '#16211D',
    backgroundSelected: '#1E2C26',
    border: '#2A3D35',
    primary: '#3FAE87',
    primaryText: '#06231A',
    primarySubtle: '#16211D',
    primarySubtleBorder: '#2A3D35',
    success: '#3FAE87',
    warning: '#E3A455',
    danger: '#D97A63',
  },
} as const;

export type ThemeColor = keyof typeof Colors.light & keyof typeof Colors.dark;

export const Fonts = Platform.select({
  ios: {
    /** iOS `UIFontDescriptorSystemDesignDefault` */
    sans: 'system-ui',
    /** iOS `UIFontDescriptorSystemDesignSerif` */
    serif: 'ui-serif',
    /** iOS `UIFontDescriptorSystemDesignRounded` */
    rounded: 'ui-rounded',
    /** iOS `UIFontDescriptorSystemDesignMonospaced` */
    mono: 'ui-monospace',
  },
  default: {
    sans: 'normal',
    serif: 'serif',
    rounded: 'normal',
    mono: 'monospace',
  },
  web: {
    sans: 'var(--font-display)',
    serif: 'var(--font-serif)',
    rounded: 'var(--font-rounded)',
    mono: 'var(--font-mono)',
  },
});

export const Spacing = {
  half: 2,
  one: 4,
  two: 8,
  three: 16,
  four: 24,
  five: 32,
  six: 64,
} as const;

export const BottomTabInset = Platform.select({ ios: 50, android: 80 }) ?? 0;
export const MaxContentWidth = 800;
