import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { VideoShowcase } from "@/components/VideoShowcase";

export default function VideosPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Selected Videos</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 760 }}>
            Curated clips recorded from the Deep Faced Mac app. The website is only for downloading
            the app and displaying selected recordings.
          </Typography>
        </Stack>
        <VideoShowcase />
      </Stack>
    </AppShell>
  );
}
