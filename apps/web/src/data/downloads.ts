import type { DesktopRelease } from "@deep-faced/shared";

export const desktopReleases: DesktopRelease[] = [
  {
    id: "macos-alpha",
    platform: "macos",
    label: "Download for macOS",
    version: "0.1.0-alpha",
    status: "available",
    href: "/downloads/deep-faced-mac-alpha.dmg",
    notes: "macOS app bundle with camera permission metadata, Deep Faced icon, local face tracking, and composed-frame virtual camera pipeline.",
  },
  {
    id: "ios-later",
    platform: "ios",
    label: "iPhone companion waitlist",
    version: "planned",
    status: "planned",
    href: "mailto:hello@deepfaced.app?subject=iPhone%20companion%20waitlist",
    notes: "Planned for a later Continuity Camera-style companion workflow, not a browser virtual camera.",
  },
];
