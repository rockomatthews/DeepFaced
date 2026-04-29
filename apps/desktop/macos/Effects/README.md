# DeepAR Effects

Put downloaded DeepAR effects in this folder as one directory per effect.

Expected shape:

```text
Effects/
  Vendetta Mask/
    Vendetta_Mask.deepar
    preview.png
    models/
    textures/
    shaders/
  Ping Pong Minigame/
    Ping_Pong.deepar
    preview.png
    scripts/
    textures/
```

The Mac app scans each immediate child folder, finds the first `.deepar` file, and keeps the whole
folder intact when packaging. This preserves companion files like previews, textures, models,
scripts, shaders, and audio files.

The packaged app receives these files at:

```text
Deep Faced.app/Contents/Resources/Effects/
```
