import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { communityFaces, featuredCreators } from "@deep-faced/effects";
import { AppShell } from "@/components/AppShell";
import { FaceGallery } from "@/components/FaceGallery";

type CreatorPageProps = {
  params: Promise<{
    handle: string;
  }>;
};

export function generateStaticParams() {
  return featuredCreators.map((creator) => ({ handle: creator.handle }));
}

export default async function CreatorPage({ params }: CreatorPageProps) {
  const { handle } = await params;
  const creator = featuredCreators.find((candidate) => candidate.handle === handle) ?? featuredCreators[0];
  const faces = communityFaces.filter((face) => face.creator.handle === creator.handle);

  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Button href="/faces" variant="text" sx={{ alignSelf: "flex-start" }}>
          Browse all faces
        </Button>

        <Card>
          <CardContent>
            <Stack direction={{ xs: "column", md: "row" }} spacing={3} sx={{ alignItems: { md: "center" } }}>
              <Box
                sx={{
                  width: 108,
                  height: 108,
                  borderRadius: "50%",
                  background: creator.avatarGradient,
                  flex: "0 0 auto",
                }}
              />
              <Box sx={{ flex: 1 }}>
                <Stack direction="row" spacing={1} sx={{ alignItems: "center", flexWrap: "wrap", gap: 1 }}>
                  <Typography variant="h2">{creator.displayName}</Typography>
                  {creator.verified && <Chip label="verified" color="success" />}
                </Stack>
                <Typography color="text.secondary" sx={{ mt: 0.5 }}>
                  @{creator.handle}
                </Typography>
                <Typography color="text.secondary" sx={{ mt: 1.5, maxWidth: 760 }}>
                  {creator.bio ?? "DeepAR creator publishing faces and camera-ready wearables for Deep Faced."}
                </Typography>
              </Box>
              <Button href="/upload" variant="contained">
                Upload Face
              </Button>
            </Stack>
          </CardContent>
        </Card>

        <Stack spacing={2}>
          <Typography variant="h3">Published effects</Typography>
          <FaceGallery faces={faces} />
        </Stack>
      </Stack>
    </AppShell>
  );
}
