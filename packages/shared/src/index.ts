export type EffectCategory =
  | "robot"
  | "alien"
  | "cartoon"
  | "helmet"
  | "villain"
  | "mascot"
  | "glasses"
  | "beauty"
  | "background"
  | "wearable"
  | "celebrity-parody"
  | "creator-original";

export type DeepAREffectKind =
  | "face"
  | "face-wearable"
  | "glasses"
  | "background"
  | "beauty-preset"
  | "wrist-wearable"
  | "foot-wearable"
  | "other";

export type DeepARFeatureFlag =
  | "face-tracking"
  | "multi-face"
  | "glasses-vto"
  | "head-occluder"
  | "face-rig"
  | "dense-face-mesh"
  | "blend-shapes"
  | "bone-driven"
  | "2d-eyes"
  | "2d-lips"
  | "beauty-api"
  | "background-segmentation"
  | "physics"
  | "scripting"
  | "triggers"
  | "particles"
  | "sound"
  | "video-textures"
  | "wrist-tracking"
  | "foot-tracking";

export type DeepARCreationTrack =
  | "studio-export"
  | "parameterized-template"
  | "beauty-preset"
  | "source-remix";

export type DeepARCompatiblePlatform = "macos" | "web" | "ios" | "android";

export type EffectParameterKey =
  | "intensity"
  | "accentHue"
  | "glow"
  | "scale"
  | "alignment"
  | "faceShape"
  | "noseSize"
  | "eyeSize"
  | "chinSize"
  | "lipFullness";

export type EffectParameter = {
  key: EffectParameterKey;
  label: string;
  min: number;
  max: number;
  step: number;
  defaultValue: number;
  unit?: string;
};

export type DeepARTemplateParameter = {
  key: string;
  label: string;
  nodeName: string;
  componentName: "" | "MeshRenderer" | "PhysicsWorld" | string;
  parameterName: string;
  valueType: "float" | "bool" | "vector3" | "vector4" | "texture" | "string";
  defaultValue: number | boolean | string | number[];
  min?: number;
  max?: number;
  step?: number;
};

export type EffectPerformanceBudget = {
  maxTextureSize: 512 | 1024 | 2048;
  maxTextureSizeHardLimit: 2048;
  maxPolygonsPerMesh: number;
  maxPolygonsTotal: number;
  maxSceneObjects: number;
  targetFps: 24 | 30 | 60;
  packageWarningMb: number;
};

export type EffectLicense = {
  source: "internal" | "deepar-template" | "third-party" | "user-upload";
  label: string;
  attributionRequired: boolean;
  consentRequired: boolean;
};

export type DeepFacedEffect = {
  id: string;
  slug: string;
  name: string;
  kind: DeepAREffectKind;
  category: EffectCategory;
  description: string;
  assetPath: string;
  thumbnailPath?: string;
  previewVideoPath?: string;
  sourceProjectPath?: string;
  thumbnailGradient: string;
  creationTrack: DeepARCreationTrack;
  featureFlags: DeepARFeatureFlag[];
  compatiblePlatforms: DeepARCompatiblePlatform[];
  parameters: EffectParameter[];
  templateParameters: DeepARTemplateParameter[];
  defaultParameters: Partial<Record<EffectParameterKey, number>>;
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
  bio?: string;
  websiteUrl?: string;
  avatarPath?: string;
};

export type CommunityEffectVisibility = "private" | "unlisted" | "public";

export type CommunityEffectReviewStatus = "draft" | "pending-review" | "approved" | "rejected";

export type CommunityFace = DeepFacedEffect & {
  creator: CreatorProfile;
  visibility: CommunityEffectVisibility;
  reviewStatus: CommunityEffectReviewStatus;
  downloadCount: number;
  tryOnCount: number;
  publishedAt?: string;
  storageBucket: "face-effects";
  packageSizeMb: number;
  deepArStudioVersion: string;
  moderationNotes?: string;
};

export type FaceUploadSubmission = {
  name: string;
  slug: string;
  kind: DeepAREffectKind;
  category: EffectCategory;
  description: string;
  creatorId: string;
  effectPackagePath: string;
  thumbnailPath?: string;
  previewVideoPath?: string;
  sourceProjectPath?: string;
  creationTrack: DeepARCreationTrack;
  featureFlags: DeepARFeatureFlag[];
  compatiblePlatforms: DeepARCompatiblePlatform[];
  license: EffectLicense;
  consentStatement?: string;
  tags: string[];
};

export type EffectPreset = {
  id: string;
  name: string;
  effectId: string;
  parameters: Partial<Record<EffectParameterKey, number>>;
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
