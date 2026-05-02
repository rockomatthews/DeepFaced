import AccountCircleIcon from "@mui/icons-material/AccountCircle";
import Alert from "@mui/material/Alert";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import TextField from "@mui/material/TextField";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";

export default function ProfilePage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={2}>
          <Chip label="Creator profile" color="secondary" variant="outlined" sx={{ alignSelf: "flex-start" }} />
          <Typography variant="h2">Your Deep Faced profile</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 820 }}>
            Profiles give uploaded faces a creator identity, handle, attribution, and future remix
            permissions. Supabase Auth will back this screen.
          </Typography>
          <Alert severity="info" sx={{ maxWidth: 820 }}>
            Auth is not connected in this scaffold yet. The form mirrors the `creator_profiles`
            table so the next step can submit it directly.
          </Alert>
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "0.8fr 1.2fr" },
            gap: 3,
          }}
        >
          <Card>
            <CardContent>
              <Stack spacing={2} sx={{ alignItems: "center", textAlign: "center" }}>
                <Box
                  sx={{
                    width: 128,
                    height: 128,
                    borderRadius: "50%",
                    background: "linear-gradient(135deg, #22d3ee, #7c3aed)",
                    display: "grid",
                    placeItems: "center",
                  }}
                >
                  <AccountCircleIcon sx={{ fontSize: 72 }} />
                </Box>
                <Typography variant="h4">Creator card</Typography>
                <Typography color="text.secondary">
                  This profile appears on face detail pages, uploads, and the Mac app catalog.
                </Typography>
              </Stack>
            </CardContent>
          </Card>

          <Card>
            <CardContent>
              <Stack spacing={2.5}>
                <Typography variant="h4">Profile details</Typography>
                <TextField label="Handle" placeholder="oddmask" fullWidth />
                <TextField label="Display name" placeholder="Odd Mask Lab" fullWidth />
                <TextField label="Website" placeholder="https://example.com" fullWidth />
                <TextField label="Bio" multiline minRows={4} fullWidth />
                <Button variant="contained" sx={{ alignSelf: "flex-start" }}>
                  Save Profile
                </Button>
              </Stack>
            </CardContent>
          </Card>
        </Box>
      </Stack>
    </AppShell>
  );
}
