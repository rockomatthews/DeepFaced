import type { CommunityFace } from "@deep-faced/shared";
import DownloadIcon from "@mui/icons-material/Download";
import PlayCircleIcon from "@mui/icons-material/PlayCircle";
import VerifiedIcon from "@mui/icons-material/Verified";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";

type CommunityFaceCardProps = {
  face: CommunityFace;
};

export function CommunityFaceCard({ face }: CommunityFaceCardProps) {
  return (
    <Card sx={{ height: "100%" }}>
      <CardContent>
        <Box
          sx={{
            height: 180,
            borderRadius: 4,
            background: face.thumbnailGradient,
            border: "1px solid rgba(255,255,255,0.2)",
            position: "relative",
            overflow: "hidden",
          }}
        >
          <Box
            sx={{
              position: "absolute",
              inset: "18% 28%",
              borderRadius: "44% 44% 50% 50%",
              border: "2px solid rgba(255,255,255,0.66)",
              boxShadow: "0 0 44px rgba(255,255,255,0.32)",
            }}
          />
        </Box>

        <Stack spacing={2} sx={{ mt: 2 }}>
          <Box>
            <Stack direction="row" spacing={1} sx={{ alignItems: "center" }}>
              <Typography variant="h5" sx={{ fontWeight: 800 }}>
                {face.name}
              </Typography>
              {face.creator.verified ? <VerifiedIcon color="secondary" fontSize="small" /> : null}
            </Stack>
            <Typography variant="body2" color="text.secondary">
              by @{face.creator.handle}
            </Typography>
          </Box>

          <Typography color="text.secondary">{face.description}</Typography>

          <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap" }}>
            <Chip size="small" label={face.category} />
            <Chip size="small" label={`${face.packageSizeMb} MB`} />
            <Chip size="small" label={`${face.tryOnCount.toLocaleString()} try-ons`} />
          </Stack>

          <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
            <Button href={`/booth?effect=${face.id}`} variant="contained" startIcon={<PlayCircleIcon />}>
              Try On
            </Button>
            <Button href={face.assetPath} variant="outlined" startIcon={<DownloadIcon />}>
              Download
            </Button>
          </Stack>
        </Stack>
      </CardContent>
    </Card>
  );
}
