import { starterEffects } from "@deep-faced/effects";
import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { EffectCard } from "@/components/EffectCard";

export default function MasksPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Mask Library</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 780 }}>
            Starter metadata for vetted DeepAR packages. Production assets should include package
            URLs, license notes, consent requirements, and performance budgets before publishing.
          </Typography>
        </Stack>

        <Box
          sx={{
            display: "grid",
            gridTemplateColumns: { xs: "1fr", md: "repeat(2, 1fr)", xl: "repeat(4, 1fr)" },
            gap: 2,
          }}
        >
          {starterEffects.map((effect) => (
            <EffectCard key={effect.id} effect={effect} />
          ))}
        </Box>

        <Card>
          <CardContent>
            <Typography variant="h4">Effect Metadata Contract</Typography>
            <Typography color="text.secondary" sx={{ mt: 1, maxWidth: 900 }}>
              Each mask is treated as a packaged effect, not a loose 3D model. The shared model
              tracks asset paths, adjustable parameters, licensing, consent, and web performance
              budgets so the gallery, creator, booth, and desktop companion can use the same data.
            </Typography>
            <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap", mt: 2 }}>
              <Chip label="assetPath" />
              <Chip label="parameters" />
              <Chip label="license" />
              <Chip label="performance" />
              <Chip label="tags" />
            </Stack>
          </CardContent>
        </Card>
      </Stack>
    </AppShell>
  );
}
