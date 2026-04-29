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
  ["Mac app first", "Download the desktop app to use Deep Faced effects with your camera."],
  ["Selected recordings", "The site displays curated videos recorded from the Mac app."],
  ["No web editor", "Masks and effects live in the app, not as browser editing tools."],
];

export default function Home() {
  return (
    <AppShell>
      <Stack spacing={8} sx={{ py: { xs: 6, md: 10 } }}>
        <Stack spacing={4} sx={{ alignItems: "center", textAlign: "center" }}>
          <Chip label="Mac camera effects app" color="secondary" variant="outlined" />
          <Typography variant="h1" sx={{ maxWidth: 980, fontSize: { xs: 56, md: 104 } }}>
            Deep Faced for Mac.
          </Typography>
          <Typography variant="h5" color="text.secondary" sx={{ maxWidth: 780 }}>
            Download the Mac app to use face effects with your camera. The website is a simple home
            for the app download and selected videos recorded from the app.
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
