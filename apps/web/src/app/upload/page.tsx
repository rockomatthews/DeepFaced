import UploadFileIcon from "@mui/icons-material/UploadFile";
import Alert from "@mui/material/Alert";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Divider from "@mui/material/Divider";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";

const checklist = [
  "Export a `.deepar` runtime package from DeepAR Studio.",
  "Keep the package near 5 MB when possible and review warnings over 10 MB.",
  "Use textures around 512x512 where possible; 2048x2048 is the hard ceiling.",
  "Keep meshes under 25k polygons each and under 100k polygons total.",
  "Include attribution and license notes for third-party models, textures, or sounds.",
  "Optional: upload a source `.deeparproj` or zip so other creators can remix later.",
];

const featureFlags = [
  "face-tracking",
  "glasses-vto",
  "head-occluder",
  "face-rig",
  "blend-shapes",
  "scripting",
  "physics",
  "background-segmentation",
];

export default function UploadPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={2}>
          <Chip label="Creator upload" color="secondary" variant="outlined" sx={{ alignSelf: "flex-start" }} />
          <Typography variant="h2">Upload a DeepAR face</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 860 }}>
            Deep Faced accepts Studio-exported `.deepar` files first. The app will later add
            parameterized templates and Beauty presets, but full face and wearable creation belongs
            in DeepAR Studio.
          </Typography>
          <Alert severity="info" sx={{ maxWidth: 860 }}>
            Auth-backed uploads are the next wiring step. This page defines the creator submission
            fields and DeepAR review checklist that will connect to Supabase Storage.
          </Alert>
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", lg: "1.1fr 0.9fr" },
            gap: 3,
          }}
        >
          <Card>
            <CardContent>
              <Stack spacing={2.5}>
                <Typography variant="h4">Effect metadata</Typography>
                <TextField label="Face name" placeholder="Vendetta Neon Mask" fullWidth />
                <TextField label="Slug" placeholder="vendetta-neon-mask" fullWidth />
                <TextField label="Short description" multiline minRows={3} fullWidth />
                <TextField label="Category" placeholder="face, glasses, wearable, beauty, background" fullWidth />
                <TextField label="Tags" placeholder="mask, villain, face-tracking" fullWidth />

                <Divider />

                <Typography variant="h5">DeepAR files</Typography>
                <Button startIcon={<UploadFileIcon />} variant="outlined" component="label">
                  Choose .deepar package
                  <input hidden type="file" accept=".deepar" />
                </Button>
                <Button startIcon={<UploadFileIcon />} variant="outlined" component="label">
                  Optional source project zip
                  <input hidden type="file" accept=".zip,.deeparproj" />
                </Button>
                <Button startIcon={<UploadFileIcon />} variant="outlined" component="label">
                  Thumbnail or preview image
                  <input hidden type="file" accept="image/*" />
                </Button>

                <Divider />

                <Typography variant="h5">Feature flags</Typography>
                <Stack direction="row" spacing={1} sx={{ flexWrap: "wrap", gap: 1 }}>
                  {featureFlags.map((flag) => (
                    <Chip key={flag} label={flag.replaceAll("-", " ")} variant="outlined" />
                  ))}
                </Stack>

                <Button variant="contained" size="large">
                  Submit for Review
                </Button>
              </Stack>
            </CardContent>
          </Card>

          <Stack spacing={2}>
            <Card>
              <CardContent>
                <Typography variant="h4">DeepAR review checklist</Typography>
                <Stack component="ol" spacing={1.5} sx={{ pl: 3, mt: 2 }}>
                  {checklist.map((item) => (
                    <Typography component="li" key={item} color="text.secondary">
                      {item}
                    </Typography>
                  ))}
                </Stack>
              </CardContent>
            </Card>

            <Card>
              <CardContent>
                <Typography variant="h4">Creation tracks</Typography>
                <Stack spacing={1.25} sx={{ mt: 2 }}>
                  <Typography color="text.secondary">
                    <strong>Now:</strong> Studio-exported `.deepar` uploads.
                  </Typography>
                  <Typography color="text.secondary">
                    <strong>Next:</strong> approved templates with editable DeepAR parameters.
                  </Typography>
                  <Typography color="text.secondary">
                    <strong>Later:</strong> Beauty API presets if production licensing is available.
                  </Typography>
                </Stack>
              </CardContent>
            </Card>
          </Stack>
        </Box>
      </Stack>
    </AppShell>
  );
}
