import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { AppShell } from "@/components/AppShell";
import { tutorials } from "@/data/tutorials";

export default function TutorialsPage() {
  return (
    <AppShell>
      <Stack spacing={4} sx={{ py: { xs: 4, md: 6 } }}>
        <Stack spacing={1}>
          <Typography variant="h2">Creator Tutorials</Typography>
          <Typography color="text.secondary" sx={{ maxWidth: 820 }}>
            Learn how to create face meshes, prepare them for DeepAR Studio, and publish them safely
            to the Deep Faced community library.
          </Typography>
        </Stack>

        <Box sx={{ display: "grid", gridTemplateColumns: { xs: "1fr", lg: "repeat(3, 1fr)" }, gap: 2 }}>
          {tutorials.map((tutorial) => (
            <Card key={tutorial.id}>
              <CardContent>
                <Stack spacing={2}>
                  <Stack direction="row" spacing={1}>
                    <Chip label={tutorial.level} color="secondary" />
                    <Chip label={`${tutorial.estimatedMinutes} min`} />
                  </Stack>
                  <Typography variant="h4">{tutorial.title}</Typography>
                  <Typography color="text.secondary">{tutorial.summary}</Typography>
                  <Box component="ol" sx={{ pl: 2.5, m: 0 }}>
                    {tutorial.steps.map((step) => (
                      <Typography component="li" key={step} color="text.secondary" sx={{ mb: 1 }}>
                        {step}
                      </Typography>
                    ))}
                  </Box>
                  <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap" }}>
                    {tutorial.tools.map((tool) => (
                      <Chip key={tool} label={tool} size="small" />
                    ))}
                  </Stack>
                </Stack>
              </CardContent>
            </Card>
          ))}
        </Box>
      </Stack>
    </AppShell>
  );
}
