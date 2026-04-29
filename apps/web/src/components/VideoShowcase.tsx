import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { showcaseVideos } from "@/data/showcaseVideos";

export function VideoShowcase() {
  return (
    <Box
      sx={{
        display: "grid",
        gridTemplateColumns: { xs: "1fr", md: "repeat(3, 1fr)" },
        gap: 2,
      }}
    >
      {showcaseVideos.map((video) => (
        <Card key={video.id}>
          <CardContent>
            <Box
              sx={{
                aspectRatio: "16 / 9",
                borderRadius: 3,
                overflow: "hidden",
                background: video.posterGradient,
                border: "1px solid rgba(255,255,255,0.18)",
                display: "grid",
                placeItems: "center",
              }}
            >
              {video.videoSrc ? (
                <Box
                  component="video"
                  src={video.videoSrc}
                  controls
                  playsInline
                  preload="metadata"
                  sx={{ width: "100%", height: "100%", objectFit: "cover" }}
                />
              ) : (
                <Stack spacing={1} sx={{ alignItems: "center", textAlign: "center", p: 3 }}>
                  <Typography variant="h5" sx={{ fontWeight: 800 }}>
                    Video Slot
                  </Typography>
                  <Typography variant="body2" sx={{ color: "rgba(255,255,255,0.76)" }}>
                    Add an exported Mac app recording to publish this clip.
                  </Typography>
                </Stack>
              )}
            </Box>

            <Stack spacing={1.5} sx={{ mt: 2 }}>
              <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap" }}>
                <Chip size="small" label={video.maskName} />
                <Chip size="small" label={`Recorded by ${video.recordedBy}`} />
              </Stack>
              <Typography variant="h5" sx={{ fontWeight: 800 }}>
                {video.title}
              </Typography>
              <Typography color="text.secondary">{video.description}</Typography>
            </Stack>
          </CardContent>
        </Card>
      ))}
    </Box>
  );
}
