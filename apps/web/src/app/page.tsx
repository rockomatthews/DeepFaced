import ArrowForwardIcon from "@mui/icons-material/ArrowForward";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { DownloadButtons } from "@/components/DownloadButtons";
import { VideoShowcase } from "@/components/VideoShowcase";

const stats = [
  ["Mac app first", "Use DeepAR faces and wearables with your real webcam."],
  ["Creator profiles", "Upload Studio-exported .deepar effects and share them with the community."],
  ["Snap Camera style", "Browse published faces, install them, and switch effects in the Mac app."],
];

export default function Home() {
  return (
    <AppShell>
      <Stack spacing={8} sx={{ py: { xs: 6, md: 10 } }}>
        <Stack spacing={4} sx={{ alignItems: "center", textAlign: "center" }}>
          <Chip label="DeepAR faces for webcams" color="secondary" variant="outlined" />
          <Typography variant="h1" sx={{ maxWidth: 980, fontSize: { xs: 56, md: 104 } }}>
            Make faces. Use them on camera.
          </Typography>
          <Typography variant="h5" color="text.secondary" sx={{ maxWidth: 780 }}>
            Deep Faced is becoming a Snap Camera-style catalog for DeepAR faces and 3D wearables:
            creator profiles on the web, a shared effect gallery, and a Mac app that runs them live.
          </Typography>
          <Stack direction={{ xs: "column", sm: "row" }} spacing={2}>
            <Button
              href="/download"
              size="large"
              variant="contained"
              endIcon={<ArrowForwardIcon />}
            >
              Download for Mac
            </Button>
            <Button href="/faces" size="large" variant="outlined">
              Browse Faces
            </Button>
            <Button href="/videos" size="large" variant="outlined">
              Watch Videos
            </Button>
          </Stack>
          <DownloadButtons />
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "repeat(3, 1fr)" },
            gap: 2,
          }}
        >
          {stats.map(([title, description]) => (
            <Card key={title}>
              <CardContent>
                <Typography variant="h5" sx={{ fontWeight: 800 }}>
                  {title}
                </Typography>
                <Typography color="text.secondary" sx={{ mt: 1 }}>
                  {description}
                </Typography>
              </CardContent>
            </Card>
          ))}
        </Box>

        <Stack spacing={3}>
          <Stack
            direction={{ xs: "column", md: "row" }}
            spacing={2}
            sx={{ justifyContent: "space-between" }}
          >
            <Box>
              <Typography variant="h3">Selected Videos</Typography>
              <Typography color="text.secondary">
                Curated clips recorded in the Mac app.
              </Typography>
            </Box>
            <Button href="/videos" variant="text">
              View all videos
            </Button>
          </Stack>
          <VideoShowcase />
        </Stack>
      </Stack>
    </AppShell>
  );
}
