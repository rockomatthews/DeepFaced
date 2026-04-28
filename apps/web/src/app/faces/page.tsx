import { communityFaces } from "@deep-faced/effects";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { CommunityFaceCard } from "@/components/marketplace/CommunityFaceCard";

export default function FacesPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack direction={{ xs: "column", md: "row" }} spacing={2} sx={{ justifyContent: "space-between" }}>
          <Box>
            <Typography variant="h2">Community Faces</Typography>
            <Typography color="text.secondary" sx={{ maxWidth: 780 }}>
              A marketplace-style library for faces created and uploaded by the community. Published
              faces can be tried on in the browser or downloaded for the desktop app.
            </Typography>
          </Box>
          <Stack direction={{ xs: "column", sm: "row" }} spacing={1}>
            <Button href="/upload" variant="contained">
              Upload a Face
            </Button>
            <Button href="/download" variant="outlined">
              Get Desktop App
            </Button>
          </Stack>
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "repeat(2, 1fr)", xl: "repeat(4, 1fr)" },
            gap: 2,
          }}
        >
          {communityFaces.map((face) => (
            <CommunityFaceCard key={face.id} face={face} />
          ))}
        </Box>

        <Card>
          <CardContent>
            <Typography variant="h4">Supabase-backed publishing</Typography>
            <Typography color="text.secondary" sx={{ mt: 1, maxWidth: 900 }}>
              In production, this page reads published records from Supabase Postgres and package
              files from Supabase Storage in the Vercel project. The local fixtures mirror that data
              contract so the UI is ready before the database is provisioned.
            </Typography>
          </CardContent>
        </Card>
      </Stack>
    </AppShell>
  );
}
