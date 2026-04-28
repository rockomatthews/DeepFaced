import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { FaceCreator } from "@/components/FaceCreator";

export default function CreatePage() {
  return (
    <AppShell>
      <Stack spacing={3} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Create a Face</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 780 }}>
            The MVP creator starts with parameterized character masks. Photo-derived or custom 3D
            masks can come later through a consent-aware review pipeline.
          </Typography>
        </Stack>
        <FaceCreator />
      </Stack>
    </AppShell>
  );
}
