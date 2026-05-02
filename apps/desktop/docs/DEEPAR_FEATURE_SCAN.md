# DeepAR Feature Scan

Deep Faced should treat DeepAR as two related products:

1. DeepAR Studio creates effects.
2. DeepAR SDK loads and controls exported effects at runtime.

The Mac app already proves the runtime path works with exported `.deepar` files. The next product layer is creator profiles, uploads, discovery, and syncing those effects into the app.

## Creation Model

DeepAR Studio is the authoring tool for real faces, masks, and 3D wearables. It can import common 3D asset formats, compose AR scenes, add face tracking components, configure materials, attach scripts, preview, and export runtime packages.

Supported creation inputs include:

- FBX
- glTF/GLB
- COLLADA/DAE
- STL
- Textures, LUTs, image sequences, sounds, scripts, and animations

DeepAR uses two important file types:

- `.deepar`: exported runtime effect consumed by the SDK.
- `.deeparproj`: editable Studio source project containing source assets.

Deep Faced should store `.deepar` as the installable effect and optionally store a zipped `.deeparproj`/source bundle for remixing.

## Face-Specific Features

DeepAR provides first-class face creation primitives:

- Standard face tracking
- Multiple face tracking, up to four faces where supported
- Face tracking optimized for glasses virtual try-on
- Emotion detection/triggers, with platform limitations
- Reference head rig and face rig
- Default dense face mesh
- 2D lips mesh
- 2D eyes mesh
- Head occluder mesh
- Bone-driven masks and non-human face rigs
- Vertex-driven masks using required vertex colors
- Blend shapes for face morphing

Important authoring constraint: the default face mesh and 2D lip/eye meshes rely on preserved vertex colors and vertex counts. Editing those incorrectly can break tracking.

## Wearables And Try-On

DeepAR can support more than faces, but the roadmap should prioritize faces first.

Relevant wearable capabilities:

- Glasses and face-mounted 3D objects
- Head-mounted accessories such as hats, horns, helmets, masks, and hair pieces
- Wrist/watch try-on through wrist tracking, with docs now pointing partly toward ShopAR/archive pages
- Shoe/foot try-on through foot tracking, also partly archived/ShopAR-oriented
- Wrist, foot, and head occluder meshes

For Deep Faced, treat glasses and head-attached wearables as first-class. Treat wrist/foot/body wearables as later compatibility tracks that need fresh testing and licensing confirmation.

## Runtime Control

The SDK loads effects with `switchEffect` and can control loaded effects at runtime:

- Switch and clear effects by slot
- Load multiple slots, such as face plus background
- Target a specific face index where supported
- Fire custom triggers
- Change transform parameters: position, rotation, scale
- Enable or disable nodes
- Change colors and shader uniforms
- Change textures
- Change blend shape weights
- Change physics parameters
- Record video and screenshots on Web
- Use a custom video element or canvas stream on Web

This enables a future Deep Faced template system: a Studio-authored `.deepar` template exposes known node names and parameters, and the website or Mac app offers safe controls for those parameters.

## Scripting

DeepAR effects can include JavaScript scripts inside Studio projects. Scripts support callbacks including:

- `onStart`
- `onPreUpdate`
- `onUpdate`
- `onFlush`
- Collision enter/inside/leave
- Touch events
- Trigger-state changes
- Custom trigger fired

Scripts can use utilities such as changing parameters and firing custom triggers. This is useful for interactive masks and effects, but it means uploaded effects should be reviewed before becoming public.

## Beauty API

DeepAR Beauty is a separate plugin/product, not just part of the base SDK. It can adjust:

- Skin smoothing
- Face morphing
- Face makeup
- Eye makeup
- Lip makeup
- Eye coloring
- Image filters
- Background blur and replacement

Face morphing parameters include eyebrow thickness/height, forehead size, lips width/fullness, jawline shape, face shape, nose size, mouth vertical position, eye size, and chin size.

Current caveat: Beauty is separately licensed. Public docs describe a time-limited, watermarked testing build and commercial production partnership. Deep Faced should not depend on Beauty for the first production path unless licensing is resolved.

## Performance Guidelines

Upload review and validation should surface DeepAR's own performance guidance:

- Target `.deepar` size: ideally under 5 MB for mobile web, warning over 10 MB.
- Texture target: 512x512 where possible.
- Texture hard upper bound: 2048x2048.
- Web textures work best square and power-of-two.
- Geometry target: under 25k polygons per mesh.
- Scene target: under 100k polygons total.
- Object count target: no more than roughly 50 scene objects.
- Prefer static meshes when possible.
- Use bones, blend shapes, animation, video textures, physics, and scripting only when needed.
- Video textures are not supported on Web SDK.

## Deep Faced Creation Tracks

### Track 1: Studio Uploads

Users create faces and wearables in DeepAR Studio, export `.deepar`, then upload to Deep Faced with metadata, thumbnails, license information, and optional source project bundles.

This is the safest MVP and matches DeepAR's intended workflow.

### Track 2: Parameterized Templates

Deep Faced provides vetted Studio templates with known node/parameter names. Users customize colors, textures, blend shapes, toggles, scale, and triggers through web or Mac UI. The result can be stored as a preset referencing a template effect plus parameter values.

This gives users a lightweight "make a face" path without generating `.deepar` server-side.

### Track 3: Beauty Presets

If licensing allows, Deep Faced can offer Beauty-based face morph/makeup presets. These are not replacement `.deepar` effects; they are runtime parameter sets layered on top of DeepAR Beauty.

### Track 4: Full Creator Automation

Only pursue automated `.deepar` generation if DeepAR exposes a supported export API/CLI or if we build an explicit offline pipeline around Studio/project assets. Current public docs do not show a reliable server-side Studio export API.
