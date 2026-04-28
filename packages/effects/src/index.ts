import type { CommunityFace, CreatorProfile, DeepFacedEffect, EffectParameter } from "@deep-faced/shared";

const baseParameters: EffectParameter[] = [
  {
    key: "intensity",
    label: "Intensity",
    min: 0,
    max: 100,
    step: 1,
    defaultValue: 72,
    unit: "%",
  },
  {
    key: "accentHue",
    label: "Accent hue",
    min: 0,
    max: 360,
    step: 1,
    defaultValue: 188,
    unit: "deg",
  },
  {
    key: "glow",
    label: "Glow",
    min: 0,
    max: 100,
    step: 1,
    defaultValue: 42,
    unit: "%",
  },
  {
    key: "scale",
    label: "Scale",
    min: 80,
    max: 130,
    step: 1,
    defaultValue: 100,
    unit: "%",
  },
  {
    key: "alignment",
    label: "Vertical alignment",
    min: -50,
    max: 50,
    step: 1,
    defaultValue: 0,
    unit: "px",
  },
];

export const starterEffects: DeepFacedEffect[] = [
  {
    id: "cyber-visor",
    name: "Cyber Visor",
    category: "robot",
    description: "A neon face plate with a mirrored visor and reactive glow.",
    assetPath: "/effects/cyber-visor.deepar",
    thumbnailGradient: "linear-gradient(135deg, #00d4ff 0%, #7c3aed 55%, #111827 100%)",
    parameters: baseParameters,
    defaultParameters: {
      intensity: 82,
      accentHue: 188,
      glow: 72,
      scale: 104,
      alignment: -4,
    },
    license: {
      source: "internal",
      label: "Prototype asset metadata; replace with vetted DeepAR package before production.",
      attributionRequired: false,
      consentRequired: false,
    },
    performance: {
      maxTextureSize: 1024,
      maxTriangles: 12000,
      targetFps: 60,
    },
    tags: ["robot", "visor", "neon", "streaming"],
  },
  {
    id: "alien-oracle",
    name: "Alien Oracle",
    category: "alien",
    description: "A soft alien face shell with oversized eyes and color-shifting skin.",
    assetPath: "/effects/alien-oracle.deepar",
    thumbnailGradient: "linear-gradient(135deg, #a7f3d0 0%, #22c55e 45%, #0f172a 100%)",
    parameters: baseParameters,
    defaultParameters: {
      intensity: 74,
      accentHue: 142,
      glow: 36,
      scale: 98,
      alignment: 2,
    },
    license: {
      source: "deepar-template",
      label: "Template-derived placeholder for MVP testing.",
      attributionRequired: false,
      consentRequired: false,
    },
    performance: {
      maxTextureSize: 1024,
      maxTriangles: 10000,
      targetFps: 60,
    },
    tags: ["alien", "creature", "eyes", "playful"],
  },
  {
    id: "toon-villain",
    name: "Toon Villain",
    category: "villain",
    description: "A stylized comic-book villain mask with exaggerated brows and shadows.",
    assetPath: "/effects/toon-villain.deepar",
    thumbnailGradient: "linear-gradient(135deg, #f97316 0%, #dc2626 48%, #18181b 100%)",
    parameters: baseParameters,
    defaultParameters: {
      intensity: 68,
      accentHue: 12,
      glow: 24,
      scale: 102,
      alignment: 0,
    },
    license: {
      source: "internal",
      label: "Prototype asset metadata; replace with vetted DeepAR package before production.",
      attributionRequired: false,
      consentRequired: false,
    },
    performance: {
      maxTextureSize: 1024,
      maxTriangles: 9000,
      targetFps: 60,
    },
    tags: ["cartoon", "villain", "mask", "character"],
  },
  {
    id: "mascot-head",
    name: "Mascot Head",
    category: "mascot",
    description: "A friendly oversized mascot face tuned for video calls and reactions.",
    assetPath: "/effects/mascot-head.deepar",
    thumbnailGradient: "linear-gradient(135deg, #fde047 0%, #fb7185 52%, #312e81 100%)",
    parameters: baseParameters,
    defaultParameters: {
      intensity: 62,
      accentHue: 326,
      glow: 18,
      scale: 112,
      alignment: -8,
    },
    license: {
      source: "internal",
      label: "Prototype asset metadata; replace with vetted DeepAR package before production.",
      attributionRequired: false,
      consentRequired: false,
    },
    performance: {
      maxTextureSize: 1024,
      maxTriangles: 14000,
      targetFps: 30,
    },
    tags: ["mascot", "friendly", "oversized", "calls"],
  },
];

export function getStarterEffect(effectId: string): DeepFacedEffect | undefined {
  return starterEffects.find((effect) => effect.id === effectId);
}

export const featuredCreators: CreatorProfile[] = [
  {
    id: "creator-lumen",
    handle: "lumenforge",
    displayName: "Lumen Forge",
    avatarGradient: "linear-gradient(135deg, #22d3ee, #7c3aed)",
    verified: true,
  },
  {
    id: "creator-oddmask",
    handle: "oddmask",
    displayName: "Odd Mask Lab",
    avatarGradient: "linear-gradient(135deg, #f97316, #db2777)",
    verified: false,
  },
  {
    id: "creator-sable",
    handle: "sablemesh",
    displayName: "Sable Mesh",
    avatarGradient: "linear-gradient(135deg, #a7f3d0, #0f766e)",
    verified: true,
  },
];

export const communityFaces: CommunityFace[] = starterEffects.map((effect, index) => ({
  ...effect,
  creator: featuredCreators[index % featuredCreators.length],
  status: "published",
  downloadCount: [1248, 934, 771, 642][index] ?? 120,
  tryOnCount: [8450, 6232, 5119, 4908][index] ?? 900,
  publishedAt: new Date(Date.UTC(2026, 3, 20 - index)).toISOString(),
  storageBucket: "face-effects",
  packageSizeMb: [8.4, 6.9, 5.8, 11.2][index] ?? 7.5,
  deepArStudioVersion: "DeepAR Studio 5.x",
}));

export function getCommunityFace(faceId: string): CommunityFace | undefined {
  return communityFaces.find((face) => face.id === faceId);
}
