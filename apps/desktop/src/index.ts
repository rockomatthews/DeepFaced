import type { DesktopCompanionTarget } from "@deep-faced/shared";

export const desktopCompanionTargets: DesktopCompanionTarget[] = [
  {
    platform: "macos",
    preferredBackend: "macos-camera-extension",
    status: "prototype",
  },
  {
    platform: "windows",
    preferredBackend: "windows-media-foundation",
    status: "planned",
  },
  {
    platform: "ios",
    preferredBackend: "ios-continuity-camera",
    status: "planned",
  },
];

export type DesktopRenderSource = {
  presetId: string;
  effectId: string;
  source: "local-webview" | "paired-web-session";
};

export type VirtualCameraPipelineStep = {
  id: string;
  label: string;
  owner: "renderer" | "bridge" | "os-backend";
};

export const virtualCameraPipeline: VirtualCameraPipelineStep[] = [
  {
    id: "load-preset",
    label: "Load the selected Deep Faced preset and effect metadata.",
    owner: "renderer",
  },
  {
    id: "render-frames",
    label: "Render camera frames through the DeepAR adapter into an offscreen canvas.",
    owner: "renderer",
  },
  {
    id: "copy-frames",
    label: "Copy processed frames into the native frame bridge.",
    owner: "bridge",
  },
  {
    id: "publish-device",
    label: "Publish frames to the OS virtual camera device.",
    owner: "os-backend",
  },
];

export function getFirstDesktopTarget() {
  return desktopCompanionTargets[0];
}
