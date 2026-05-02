import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { communityFaces } from "@deep-faced/effects";
import { AppShell } from "@/components/AppShell";
import { FaceGallery } from "@/components/FaceGallery";

const creationTracks = [
  "Studio-exported .deepar faces",
  "3D face wearables",
  "Parameterized templates",
  "Beauty presets later",
];

export default function FacesPage() {
  return (
    <AppShell>
      <Stack spacing={5} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack direction={{ xs: "column", md: "row" }} spacing={3} sx={{ justifyContent: "space-between" }}>
          <Box>
            <Chip label="Community catalog" color="secondary" variant="outlined" sx={{ mb: 2 }} />
            <Typography variant="h2">Faces and 3D wearables</Typography>
            <Typography color="text.secondary" sx={{ maxWidth: 820, mt: 1.5 }}>
              Browse DeepAR Studio exports made by creators. Approved `.deepar` effects can be
              synced into the Mac app and used in your camera, like a modern Snap Camera catalog.
            </Typography>
          </Box>
          <Stack direction={{ xs: "column", sm: "row" }} spacing={1} sx={{ alignSelf: { md: "flex-end" } }}>
            <Button href="/upload" variant="contained">
              Upload a Face
            </Button>
            <Button href="/download" variant="outlined">
              Get Mac App
            </Button>
          </Stack>
        </Stack>

        <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1 }}>
          {creationTracks.map((track) => (
            <Chip key={track} label={track} />
          ))}
        </Stack>

        <FaceGallery faces={communityFaces} />
      </Stack>
    </AppShell>
  );
}
