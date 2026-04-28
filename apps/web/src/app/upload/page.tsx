import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";

const checklist = [
  "DeepAR `.deepar` package exported from Studio",
  "Thumbnail or preview render",
  "License and attribution notes",
  "Consent statement for any recognizable likeness",
  "Performance budget: texture size, triangles, target FPS",
];

export default function UploadPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Upload a Face</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 820 }}>
            Submit community-created DeepAR face packages for review. The production version should
            store packages in Supabase Storage and metadata in Supabase Postgres.
          </Typography>
        </Stack>

        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", lg: "1fr 0.8fr" }, gap: 3 }}>
          <Card>
            <CardContent>
              <Stack spacing={2}>
                <Typography variant="h4">Submission Details</Typography>
                <TextField label="Face name" fullWidth />
                <TextField label="Creator handle" fullWidth />
                <TextField label="Category" placeholder="robot, alien, mascot..." fullWidth />
                <TextField label="Description" minRows={4} multiline fullWidth />
                <TextField label="DeepAR package path" placeholder="face-effects/creator/face.deepar" fullWidth />
                <TextField label="Consent and licensing notes" minRows={4} multiline fullWidth />
                <Button variant="contained" disabled>
                  Submit for Review
                </Button>
                <Typography variant="body2" color="text.secondary">
                  This prototype renders the intake UI. Enable Supabase Auth and Storage before
                  accepting real uploads.
                </Typography>
              </Stack>
            </CardContent>
          </Card>

          <Card>
            <CardContent>
              <Stack spacing={2}>
                <Typography variant="h4">Before Uploading</Typography>
                {checklist.map((item) => (
                  <Chip key={item} label={item} sx={{ justifyContent: "flex-start" }} />
                ))}
              </Stack>
            </CardContent>
          </Card>
        </Box>
      </Stack>
    </AppShell>
  );
}
