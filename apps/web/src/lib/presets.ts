import type { DeepFacedEffect, EffectPreset } from "@deep-faced/shared";

export const savedPresetStorageKey = "deep-faced:saved-presets";

export function createPresetFromEffect(effect: DeepFacedEffect, name = `${effect.name} Preset`): EffectPreset {
  return {
    id: `${effect.id}-${Date.now()}`,
    name,
    effectId: effect.id,
    parameters: effect.defaultParameters,
    createdAt: new Date().toISOString(),
  };
}

export function readSavedPresets(): EffectPreset[] {
  if (typeof window === "undefined") {
    return [];
  }

  try {
    const raw = window.localStorage.getItem(savedPresetStorageKey);
    return raw ? (JSON.parse(raw) as EffectPreset[]) : [];
  } catch {
    return [];
  }
}

export function writeSavedPresets(presets: EffectPreset[]) {
  window.localStorage.setItem(savedPresetStorageKey, JSON.stringify(presets));
}
