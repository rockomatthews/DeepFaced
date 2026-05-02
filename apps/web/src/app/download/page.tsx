import Alert from "@mui/material/Alert";
import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { DownloadButtons } from "@/components/DownloadButtons";
import { desktopReleases } from "@/data/downloads";

type DownloadPageProps = {
  searchParams?: Promise<{
    download?: string;
  }>;
};

export default async function DownloadPage({ searchParams }: DownloadPageProps) {
  const params = await searchParams;
  const downloadStatus = params?.download;
  const hasDownloadUrl = Boolean(process.env.MACOS_DMG_DOWNLOAD_URL);

  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={2}>
          <Chip label="Desktop companion" color="secondary" variant="outlined" sx={{ alignSelf: "flex-start" }} />
          <Typography variant="h2">Download Deep Faced for Mac</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 820 }}>
            The Mac app is the product. Use it to run camera effects, install the virtual camera,
            and record videos that can later be selected for display on this website.
          </Typography>
          {!hasDownloadUrl && (
            <Alert severity={downloadStatus ? "warning" : "info"} sx={{ maxWidth: 820 }}>
              The Mac download has been built, but the DMG needs to be uploaded to external file
              hosting and configured with <strong>MACOS_DMG_DOWNLOAD_URL</strong> before this button
              can serve the installer in production.
            </Alert>
          )}
          <DownloadButtons />
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "repeat(2, 1fr)" },
            gap: 2,
          }}
        >
          {desktopReleases.map((release) => (
            <Card key={release.id}>
              <CardContent>
                <Typography variant="h4">{release.label}</Typography>
                <Typography color="text.secondary" sx={{ mt: 1 }}>
                  {release.notes}
                </Typography>
                <Stack direction="row" spacing={1} sx={{ mt: 2 }}>
                  <Chip label={release.platform} />
                  <Chip label={release.status} color={release.status === "available" ? "success" : "default"} />
                  <Chip label={release.version} />
                </Stack>
              </CardContent>
            </Card>
          ))}
        </Box>
      </Stack>
    </AppShell>
  );
}
