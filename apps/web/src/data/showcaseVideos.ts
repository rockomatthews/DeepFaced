export type ShowcaseVideo = {
  id: string;
  title: string;
  maskName: string;
  description: string;
  recordedBy: string;
  videoSrc?: string;
  posterGradient: string;
};

export const showcaseVideos: ShowcaseVideo[] = [
  {
    id: "cyber-visor-demo",
    title: "Cyber Visor call test",
    maskName: "Cyber Visor",
    description: "A selected clip recorded from the Mac app using the virtual camera pipeline.",
    recordedBy: "Deep Faced",
    posterGradient: "linear-gradient(135deg, #00d4ff 0%, #7c3aed 55%, #111827 100%)",
  },
  {
    id: "alien-oracle-demo",
    title: "Alien Oracle head tracking",
    maskName: "Alien Oracle",
    description: "A curated recording slot for showing how masks follow the face in the Mac app.",
    recordedBy: "Deep Faced",
    posterGradient: "linear-gradient(135deg, #a7f3d0 0%, #22c55e 45%, #0f172a 100%)",
  },
  {
    id: "toon-villain-demo",
    title: "Toon Villain meeting mode",
    maskName: "Toon Villain",
    description: "A selected video placeholder for a Mac-recorded demo clip.",
    recordedBy: "Deep Faced",
    posterGradient: "linear-gradient(135deg, #f97316 0%, #dc2626 48%, #18181b 100%)",
  },
];
