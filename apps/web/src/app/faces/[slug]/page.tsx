import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { communityFaces } from "@deep-faced/effects";
import { AppShell } from "@/components/AppShell";

type FaceDetailPageProps = {
  params: Promise<{
    slug: string;
  }>;
};

export function generateStaticParams() {
  return communityFaces.map((face) => ({ slug: face.slug }));
}

export default async function FaceDetailPage({ params }: FaceDetailPageProps) {
  const { slug } = await params;
  const face = communityFaces.find((candidate) => candidate.slug === slug) ?? communityFaces[0];

  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Button href="/faces" variant="text" sx={{ alignSelf: "flex-start" }}>
          Back to faces
        </Button>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "1.2fr 0.8fr" },
            gap: 3,
          }}
        >
          <Box
            sx={{
              minHeight: { xs: 280, md: 520 },
              borderRadius: 6,
              background: face.thumbnailGradient,
              border: "1px solid rgba(255,255,255,0.12)",
            }}
          />

          <Stack spacing={3}>
            <Stack spacing={1}>
              <Chip label={face.kind} color="secondary" sx={{ alignSelf: "flex-start" }} />
              <Typography variant="h2">{face.name}</Typography>
              <Typography color="text.secondary">by @{face.creator.handle}</Typography>
              <Typography color="text.secondary">{face.description}</Typography>
            </Stack>

            <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1 }}>
              {face.tags.map((tag) => (
                <Chip key={tag} label={tag} variant="outlined" />
              ))}
            </Stack>

            <Card>
              <CardContent>
                <Typography variant="h5">DeepAR package</Typography>
                <Stack spacing={1.25} sx={{ mt: 2 }}>
                  <Typography color="text.secondary">Creation track: {face.creationTrack.replaceAll("-", " ")}</Typography>
                  <Typography color="text.secondary">Studio version: {face.deepArStudioVersion}</Typography>
                  <Typography color="text.secondary">Package size: {face.packageSizeMb} MB</Typography>
                  <Typography color="text.secondary">Platforms: {face.compatiblePlatforms.join(", ")}</Typography>
                </Stack>
              </CardContent>
            </Card>

            <Card>
              <CardContent>
                <Typography variant="h5">Runtime features</Typography>
                <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1, mt: 2 }}>
                  {face.featureFlags.map((flag) => (
                    <Chip key={flag} label={flag.replaceAll("-", " ")} size="small" />
                  ))}
                </Stack>
              </CardContent>
            </Card>

            <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
              <Button href="/download" variant="contained">
                Use in Mac App
              </Button>
              <Button href={`/creators/${face.creator.handle}`} variant="outlined">
                View Creator
              </Button>
            </Stack>
          </Stack>
        </Box>
      </Stack>
    </AppShell>
  );
}
