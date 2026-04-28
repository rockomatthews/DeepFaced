import { communityFaces } from "@deep-faced/effects";
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
import { CommunityFaceCard } from "@/components/marketplace/CommunityFaceCard";

const stats = [
  ["Face-first", "Masks, heads, visors, and characters instead of full-body try-on."],
  ["Creator marketplace", "Download or try on faces uploaded by other creators."],
  ["Webcam native", "Preview, capture, and save presets right from the browser."],
  ["Mac virtual camera", "Install the desktop app for Zoom-style camera output."],
];

export default function Home() {
  return (
    <AppShell>
      <Stack spacing={8} sx={{ py: { xs: 6, md: 10 } }}>
        <Stack spacing={4} sx={{ alignItems: "center", textAlign: "center" }}>
          <Chip label="DeepAR-first face effects studio" color="secondary" variant="outlined" />
          <Typography variant="h1" sx={{ maxWidth: 980, fontSize: { xs: 56, md: 104 } }}>
            Become a character on camera.
          </Typography>
          <Typography variant="h5" color="text.secondary" sx={{ maxWidth: 780 }}>
            Deep Faced is a place to create fake faces, character masks, and webcam-ready looks
            for meetings, streams, and clips.
          </Typography>
          <Stack direction={{ xs: "column", sm: "row" }} spacing={2}>
            <Button
              href="/booth"
              size="large"
              variant="contained"
              endIcon={<ArrowForwardIcon />}
            >
              Open Face Booth
            </Button>
            <Button href="/create" size="large" variant="outlined">
              Create a Face
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
              <Typography variant="h3">Community Faces</Typography>
              <Typography color="text.secondary">
                Browse creator-uploaded face packages, try them on, or download them for the Mac app.
              </Typography>
            </Box>
            <Button href="/faces" variant="text">
              Browse all faces
            </Button>
          </Stack>
          <Box
            sx={{
              display: "grid",
              gridTemplateColumns: { xs: "1fr", md: "repeat(4, 1fr)" },
              gap: 2,
            }}
          >
            {communityFaces.map((face) => (
              <CommunityFaceCard key={face.id} face={face} />
            ))}
          </Box>
        </Stack>
      </Stack>
    </AppShell>
  );
}
