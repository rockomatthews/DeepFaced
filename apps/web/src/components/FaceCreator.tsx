"use client";

import { starterEffects } from "@deep-faced/effects";
import type { DeepFacedEffect, EffectParameterKey, EffectPreset } from "@deep-faced/shared";
import SaveIcon from "@mui/icons-material/Save";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import FormControl from "@mui/material/FormControl";
import InputLabel from "@mui/material/InputLabel";
import MenuItem from "@mui/material/MenuItem";
import Select from "@mui/material/Select";
import Slider from "@mui/material/Slider";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { useMemo, useState } from "react";
import { EffectCard } from "@/components/EffectCard";
import { createPresetFromEffect, readSavedPresets, writeSavedPresets } from "@/lib/presets";

export function FaceCreator() {
  const [activeEffect, setActiveEffect] = useState<DeepFacedEffect>(starterEffects[0]);
  const [preset, setPreset] = useState<EffectPreset>(() =>
    createPresetFromEffect(starterEffects[0], "My Cyber Face"),
  );
  const [savedPresets, setSavedPresets] = useState<EffectPreset[]>(() => readSavedPresets());

  const selectedEffectId = activeEffect.id;
  const previewStyle = useMemo(
    () => ({
      background: activeEffect.thumbnailGradient,
      filter: `saturate(${1 + preset.parameters.intensity / 160})`,
      transform: `scale(${preset.parameters.scale / 100}) translateY(${preset.parameters.alignment / 3}px)`,
      boxShadow: `0 0 ${12 + preset.parameters.glow}px hsla(${preset.parameters.accentHue}, 96%, 62%, 0.62)`,
    }),
    [activeEffect.thumbnailGradient, preset.parameters],
  );

  function selectBaseEffect(effectId: string) {
    const nextEffect = starterEffects.find((effect) => effect.id === effectId) ?? starterEffects[0];
    setActiveEffect(nextEffect);
    setPreset(createPresetFromEffect(nextEffect, preset.name));
  }

  function updateParameter(key: EffectParameterKey, value: number) {
    setPreset((current) => ({
      ...current,
      parameters: {
        ...current.parameters,
        [key]: value,
      },
    }));
  }

  function savePreset() {
    const nextPreset = {
      ...preset,
      id: `${preset.effectId}-${Date.now()}`,
      effectId: activeEffect.id,
      createdAt: new Date().toISOString(),
    };
    const nextPresets = [nextPreset, ...readSavedPresets()].slice(0, 24);
    writeSavedPresets(nextPresets);
    setSavedPresets(nextPresets);
  }

  return (
    <Box
      sx={{
        display: "grid",
        gridTemplateColumns: { xs: "1fr", lg: "0.9fr 1.1fr" },
        gap: 3,
      }}
    >
      <Card>
        <CardContent>
          <Stack spacing={3}>
            <Box>
              <Typography variant="h4">Build a Face Preset</Typography>
              <Typography color="text.secondary">
                Choose a vetted base mask, tune its parameters, and save the result for the booth.
              </Typography>
            </Box>

            <TextField
              label="Preset name"
              value={preset.name}
              onChange={(event) => setPreset((current) => ({ ...current, name: event.target.value }))}
              fullWidth
            />

            <FormControl fullWidth>
              <InputLabel id="base-effect-label">Base mask</InputLabel>
              <Select
                labelId="base-effect-label"
                label="Base mask"
                value={selectedEffectId}
                onChange={(event) => selectBaseEffect(event.target.value)}
              >
                {starterEffects.map((effect) => (
                  <MenuItem key={effect.id} value={effect.id}>
                    {effect.name}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>

            {activeEffect.parameters.map((parameter) => (
              <Box key={parameter.key}>
                <Stack direction="row" sx={{ alignItems: "center", justifyContent: "space-between" }}>
                  <Typography variant="body2" sx={{ fontWeight: 700 }}>
                    {parameter.label}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {preset.parameters[parameter.key]}
                    {parameter.unit}
                  </Typography>
                </Stack>
                <Slider
                  min={parameter.min}
                  max={parameter.max}
                  step={parameter.step}
                  value={preset.parameters[parameter.key]}
                  onChange={(_, value) => updateParameter(parameter.key, value as number)}
                  aria-label={parameter.label}
                />
              </Box>
            ))}

            <Button variant="contained" startIcon={<SaveIcon />} onClick={savePreset}>
              Save Face Preset
            </Button>
          </Stack>
        </CardContent>
      </Card>

      <Stack spacing={3}>
        <Card>
          <CardContent>
            <Typography variant="h5" sx={{ fontWeight: 800 }}>
              Live Preset Preview
            </Typography>
            <Box
              sx={{
                mt: 2,
                minHeight: 360,
                borderRadius: 4,
                display: "grid",
                placeItems: "center",
                overflow: "hidden",
                bgcolor: "rgba(2, 6, 23, 0.86)",
                border: "1px solid rgba(148, 163, 184, 0.2)",
              }}
            >
              <Box
                sx={{
                  width: 240,
                  height: 300,
                  borderRadius: "43% 43% 50% 50%",
                  border: "2px solid rgba(255,255,255,0.68)",
                  ...previewStyle,
                }}
              />
            </Box>
          </CardContent>
        </Card>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "repeat(2, 1fr)" },
            gap: 2,
          }}
        >
          {starterEffects.map((effect) => (
            <EffectCard
              key={effect.id}
              effect={effect}
              selected={effect.id === activeEffect.id}
              onSelect={() => selectBaseEffect(effect.id)}
            />
          ))}
        </Box>

        <Typography color="text.secondary">
          {savedPresets.length} saved preset{savedPresets.length === 1 ? "" : "s"} available for
          the local prototype.
        </Typography>
      </Stack>
    </Box>
  );
}
