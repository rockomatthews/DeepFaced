import type { Tutorial } from "@deep-faced/shared";

export const tutorials: Tutorial[] = [
  {
    id: "photo-to-mask-pipeline",
    title: "Turn Face References Into a Stylized Mask",
    level: "beginner",
    summary: "Capture consented face references, block out a mask shape, and avoid photoreal cloning.",
    tools: ["Phone camera", "Blender", "DeepAR Studio"],
    estimatedMinutes: 35,
    steps: [
      "Collect front and side references with written consent.",
      "Block out a face shell in Blender using simple forms.",
      "Exaggerate features into a character mask instead of copying identity exactly.",
      "Export glTF or FBX for DeepAR Studio import.",
    ],
  },
  {
    id: "deepar-studio-adaptation",
    title: "Adapt a Mesh for DeepAR",
    level: "intermediate",
    summary: "Prepare scale, materials, anchors, and performance budgets for web try-on.",
    tools: ["Blender", "DeepAR Studio", "Texture optimizer"],
    estimatedMinutes: 50,
    steps: [
      "Reduce polygons and texture sizes before import.",
      "Attach the mesh to the face-tracked node in DeepAR Studio.",
      "Tune eye, nose, mouth, and jaw alignment through head turns.",
      "Export a `.deepar` package and test it in the Face Booth.",
    ],
  },
  {
    id: "creator-upload-checklist",
    title: "Creator Upload Checklist",
    level: "beginner",
    summary: "Package metadata, licensing, and consent information before publishing a face.",
    tools: ["Deep Faced upload form", "Supabase Storage", "DeepAR Studio"],
    estimatedMinutes: 20,
    steps: [
      "Add a clear name, category, tags, and creator attribution.",
      "Confirm the asset license permits public download or try-on.",
      "Include consent for recognizable likenesses.",
      "Submit the effect package for moderation before publishing.",
    ],
  },
];
