export type EffectCategory =
  | "robot"
  | "alien"
  | "cartoon"
  | "helmet"
  | "villain"
  | "mascot"
  | "celebrity-parody"
  | "creator-original";

export type EffectParameterKey =
  | "intensity"
  | "accentHue"
  | "glow"
  | "scale"
  | "alignment";

export type EffectParameter = {
  key: EffectParameterKey;
  label: string;
  min: number;
  max: number;
  step: number;
  defaultValue: number;
  unit?: string;
};

export type EffectPerformanceBudget = {
  maxTextureSize: number;
  maxTriangles: number;
  targetFps: 30 | 60;
};

export type EffectLicense = {
  source: "internal" | "deepar-template" | "third-party" | "user-upload";
  label: string;
  attributionRequired: boolean;
  consentRequired: boolean;
};

export type DeepFacedEffect = {
  id: string;
  name: string;
  category: EffectCategory;
  description: string;
  assetPath: string;
  thumbnailGradient: string;
  parameters: EffectParameter[];
  defaultParameters: Record<EffectParameterKey, number>;
  license: EffectLicense;
  performance: EffectPerformanceBudget;
  tags: string[];
};

export type CreatorProfile = {
  id: string;
  handle: string;
  displayName: string;
  avatarGradient: string;
  verified: boolean;
};

export type CommunityFaceStatus = "draft" | "pending-review" | "published" | "rejected";

export type CommunityFace = DeepFacedEffect & {
  creator: CreatorProfile;
  status: CommunityFaceStatus;
  downloadCount: number;
  tryOnCount: number;
  publishedAt: string;
  storageBucket: "face-effects";
  packageSizeMb: number;
  deepArStudioVersion: string;
};

export type FaceUploadSubmission = {
  name: string;
  category: EffectCategory;
  description: string;
  creatorId: string;
  sourceAssetPath: string;
  effectPackagePath?: string;
  license: EffectLicense;
  consentStatement: string;
};

export type EffectPreset = {
  id: string;
  name: string;
  effectId: string;
  parameters: Record<EffectParameterKey, number>;
  createdAt: string;
};

export type CaptureMode = "screenshot" | "clip";

export type CaptureSettings = {
  mode: CaptureMode;
  width: number;
  height: number;
  fps: 30 | 60;
};

export type DesktopVirtualCameraBackend =
  | "macos-camera-extension"
  | "windows-directshow"
  | "windows-media-foundation"
  | "ios-continuity-camera";

export type DesktopCompanionTarget = {
  platform: "macos" | "windows" | "ios";
  preferredBackend: DesktopVirtualCameraBackend;
  status: "planned" | "prototype" | "supported";
};

export type DesktopRelease = {
  id: string;
  platform: "macos" | "ios";
  label: string;
  version: string;
  status: "available" | "waitlist" | "planned";
  href: string;
  notes: string;
};

export type Tutorial = {
  id: string;
  title: string;
  level: "beginner" | "intermediate" | "advanced";
  summary: string;
  steps: string[];
  tools: string[];
  estimatedMinutes: number;
};
