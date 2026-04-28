import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { FaceBooth } from "@/components/FaceBooth";

export default function BoothPage() {
  return (
    <AppShell>
      <Stack spacing={3} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Face Booth</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 760 }}>
            Start your webcam, choose a character face, tune the look, then capture screenshots or
            clips. This is the browser experience that the desktop virtual camera companion will
            reuse.
          </Typography>
        </Stack>
        <FaceBooth />
      </Stack>
    </AppShell>
  );
}
