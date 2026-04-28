"use client";

import { createDeepARSession, type DeepARSession } from "@deep-faced/ar-engine";
import { starterEffects } from "@deep-faced/effects";
import type { DeepFacedEffect, EffectParameterKey, EffectPreset } from "@deep-faced/shared";
import CameraAltIcon from "@mui/icons-material/CameraAlt";
import FiberManualRecordIcon from "@mui/icons-material/FiberManualRecord";
import SaveIcon from "@mui/icons-material/Save";
import StopCircleIcon from "@mui/icons-material/StopCircle";
import VideocamIcon from "@mui/icons-material/Videocam";
import Alert from "@mui/material/Alert";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Slider from "@mui/material/Slider";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { useEffect, useMemo, useRef, useState } from "react";
import { EffectCard } from "@/components/EffectCard";
import { createPresetFromEffect, readSavedPresets, writeSavedPresets } from "@/lib/presets";

type CameraState = "idle" | "starting" | "ready" | "error";

const canvasWidth = 1280;
const canvasHeight = 720;

export function FaceBooth() {
  const videoRef = useRef<HTMLVideoElement | null>(null);
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const mediaStreamRef = useRef<MediaStream | null>(null);
  const sessionRef = useRef<DeepARSession | null>(null);
  const recorderRef = useRef<MediaRecorder | null>(null);
  const chunksRef = useRef<Blob[]>([]);
  const [cameraState, setCameraState] = useState<CameraState>("idle");
  const [error, setError] = useState<string | null>(null);
  const [activeEffect, setActiveEffect] = useState<DeepFacedEffect>(starterEffects[0]);
  const [preset, setPreset] = useState<EffectPreset>(() => createPresetFromEffect(starterEffects[0]));
  const [isRecording, setIsRecording] = useState(false);
  const [savedCount, setSavedCount] = useState(() => readSavedPresets().length);

  const parameterMap = useMemo(
    () => new Map(activeEffect.parameters.map((parameter) => [parameter.key, parameter])),
    [activeEffect.parameters],
  );

  useEffect(() => {
    return () => {
      sessionRef.current?.stop();
      mediaStreamRef.current?.getTracks().forEach((track) => track.stop());
    };
  }, []);

  function selectEffect(effect: DeepFacedEffect) {
    const nextPreset = createPresetFromEffect(effect);
    setActiveEffect(effect);
    setPreset(nextPreset);
    sessionRef.current?.setEffect(effect, nextPreset);
  }

  async function startCamera() {
    if (!videoRef.current || !canvasRef.current) {
      return;
    }

    setCameraState("starting");
    setError(null);

    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: canvasWidth },
          height: { ideal: canvasHeight },
          facingMode: "user",
        },
        audio: false,
      });

      mediaStreamRef.current = stream;
      videoRef.current.srcObject = stream;
      await videoRef.current.play();

      sessionRef.current?.stop();
      sessionRef.current = createDeepARSession({
        video: videoRef.current,
        canvas: canvasRef.current,
        effect: activeEffect,
        preset,
      });
      setCameraState("ready");
    } catch (cameraError) {
      setCameraState("error");
      setError(cameraError instanceof Error ? cameraError.message : "Unable to start the webcam.");
    }
  }

  function updateParameter(key: EffectParameterKey, value: number) {
    const nextPreset = {
      ...preset,
      parameters: {
        ...preset.parameters,
        [key]: value,
      },
    };

    setPreset(nextPreset);
    sessionRef.current?.setEffect(activeEffect, nextPreset);
  }

  function savePreset() {
    const saved = readSavedPresets();
    const nextPreset = {
      ...preset,
      id: `${preset.effectId}-${Date.now()}`,
      name: `${activeEffect.name} ${saved.length + 1}`,
      createdAt: new Date().toISOString(),
    };
    const nextPresets = [nextPreset, ...saved].slice(0, 24);
    writeSavedPresets(nextPresets);
    setSavedCount(nextPresets.length);
  }

  function downloadScreenshot() {
    const canvas = canvasRef.current;
    if (!canvas) {
      return;
    }

    const link = document.createElement("a");
    link.download = `deep-faced-${activeEffect.id}.png`;
    link.href = canvas.toDataURL("image/png");
    link.click();
  }

  function startRecording() {
    const canvas = canvasRef.current;
    if (!canvas || isRecording) {
      return;
    }

    const stream = canvas.captureStream(30);
    const recorder = new MediaRecorder(stream, { mimeType: "video/webm" });
    chunksRef.current = [];
    recorder.ondataavailable = (event) => {
      if (event.data.size > 0) {
        chunksRef.current.push(event.data);
      }
    };
    recorder.onstop = () => {
      const blob = new Blob(chunksRef.current, { type: "video/webm" });
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `deep-faced-${activeEffect.id}.webm`;
      link.click();
      URL.revokeObjectURL(url);
      setIsRecording(false);
    };
    recorderRef.current = recorder;
    recorder.start();
    setIsRecording(true);
  }

  function stopRecording() {
    recorderRef.current?.stop();
  }

  return (
    <Stack spacing={3}>
      <Card>
        <CardContent>
          <Stack direction={{ xs: "column", lg: "row" }} spacing={3}>
            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Box
                sx={{
                  position: "relative",
                  overflow: "hidden",
                  borderRadius: 4,
                  border: "1px solid rgba(148, 163, 184, 0.22)",
                  bgcolor: "rgba(2, 6, 23, 0.8)",
                  aspectRatio: "16 / 9",
                }}
              >
                <video ref={videoRef} playsInline muted style={{ display: "none" }} />
                <canvas
                  ref={canvasRef}
                  width={canvasWidth}
                  height={canvasHeight}
                  style={{ width: "100%", height: "100%", display: "block" }}
                />
                {cameraState !== "ready" ? (
                  <Stack
                    spacing={2}
                    sx={{
                      alignItems: "center",
                      justifyContent: "center",
                      position: "absolute",
                      inset: 0,
                      p: 3,
                      textAlign: "center",
                    }}
                  >
                    <VideocamIcon color="secondary" sx={{ fontSize: 56 }} />
                    <Typography variant="h4" sx={{ fontWeight: 800 }}>
                      Start your camera to try {activeEffect.name}
                    </Typography>
                    <Typography color="text.secondary" sx={{ maxWidth: 520 }}>
                      Camera frames stay local in the browser. The prototype DeepAR adapter renders
                      to this canvas so captures and the desktop companion can use the same boundary.
                    </Typography>
                    <Button
                      size="large"
                      variant="contained"
                      onClick={startCamera}
                      disabled={cameraState === "starting"}
                    >
                      {cameraState === "starting" ? "Starting camera..." : "Start Camera"}
                    </Button>
                  </Stack>
                ) : null}
              </Box>
              {error ? (
                <Alert severity="error" sx={{ mt: 2 }}>
                  {error}
                </Alert>
              ) : null}
            </Box>

            <Stack spacing={2} sx={{ width: { xs: "100%", lg: 360 } }}>
              <Stack direction="row" sx={{ alignItems: "center", justifyContent: "space-between" }}>
                <Box>
                  <Typography variant="h5" sx={{ fontWeight: 800 }}>
                    {activeEffect.name}
                  </Typography>
                  <Typography color="text.secondary" variant="body2">
                    {activeEffect.description}
                  </Typography>
                </Box>
                <Chip label={cameraState} color={cameraState === "ready" ? "success" : "default"} />
              </Stack>

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

              <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap" }}>
                <Button
                  variant="contained"
                  color="secondary"
                  startIcon={<CameraAltIcon />}
                  onClick={downloadScreenshot}
                  disabled={cameraState !== "ready"}
                >
                  Screenshot
                </Button>
                {isRecording ? (
                  <Button color="error" variant="outlined" startIcon={<StopCircleIcon />} onClick={stopRecording}>
                    Stop
                  </Button>
                ) : (
                  <Button
                    variant="outlined"
                    startIcon={<FiberManualRecordIcon />}
                    onClick={startRecording}
                    disabled={cameraState !== "ready"}
                  >
                    Clip
                  </Button>
                )}
                <Button variant="outlined" startIcon={<SaveIcon />} onClick={savePreset}>
                  Save Preset
                </Button>
              </Stack>

              <Typography variant="body2" color="text.secondary">
                {savedCount} saved preset{savedCount === 1 ? "" : "s"} stored locally.
              </Typography>

              <Alert severity="info">
                Real DeepAR `.deepar` packages and a license key can replace the prototype renderer
                without changing the Face Booth UI.
              </Alert>
            </Stack>
          </Stack>
        </CardContent>
      </Card>

      <Box
        sx={{
          display: "grid",
          gridTemplateColumns: { xs: "1fr", md: "repeat(4, 1fr)" },
          gap: 2,
        }}
      >
        {starterEffects.map((effect) => (
          <EffectCard
            key={effect.id}
            effect={effect}
            selected={parameterMap.has("intensity") && effect.id === activeEffect.id}
            onSelect={selectEffect}
          />
        ))}
      </Box>
    </Stack>
  );
}
