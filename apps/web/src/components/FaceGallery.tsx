import AutoAwesomeIcon from "@mui/icons-material/AutoAwesome";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardActions from "@mui/material/CardActions";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import type { CommunityFace } from "@deep-faced/shared";

export function FaceGallery({ faces }: { faces: CommunityFace[] }) {
  return (
    <Box
      sx={{
        display: "grid",
        gridTemplateColumns: { xs: "1fr", md: "repeat(2, 1fr)", lg: "repeat(3, 1fr)" },
        gap: 2,
      }}
    >
      {faces.map((face) => (
        <Card key={face.id} sx={{ overflow: "hidden" }}>
          <Box
            sx={{
              minHeight: 180,
              background: face.thumbnailGradient,
              display: "grid",
              placeItems: "center",
            }}
          >
            <AutoAwesomeIcon sx={{ fontSize: 56, opacity: 0.72 }} />
          </Box>
          <CardContent>
            <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1, mb: 2 }}>
              <Chip label={face.kind} size="small" />
              <Chip label={face.creationTrack.replaceAll("-", " ")} size="small" color="secondary" variant="outlined" />
            </Stack>
            <Typography variant="h5" sx={{ fontWeight: 800 }}>
              {face.name}
            </Typography>
            <Typography color="text.secondary" sx={{ mt: 0.5 }}>
              by @{face.creator.handle}
            </Typography>
            <Typography color="text.secondary" sx={{ mt: 1.5 }}>
              {face.description}
            </Typography>
            <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1, mt: 2 }}>
              {face.featureFlags.slice(0, 3).map((flag) => (
                <Chip key={flag} label={flag.replaceAll("-", " ")} size="small" variant="outlined" />
              ))}
            </Stack>
          </CardContent>
          <CardActions sx={{ px: 2, pb: 2 }}>
            <Button href={`/faces/${face.slug}`} variant="contained">
              View Face
            </Button>
            <Button href={`/creators/${face.creator.handle}`} color="inherit">
              Creator
            </Button>
          </CardActions>
        </Card>
      ))}
    </Box>
  );
}
