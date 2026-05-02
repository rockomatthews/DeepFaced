import AutoAwesomeIcon from "@mui/icons-material/AutoAwesome";
import Box from "@mui/material/Box";
import Button from "@mui/material/Button";
import Container from "@mui/material/Container";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import type { ReactNode } from "react";

export function AppShell({ children }: { children: ReactNode }) {
  return (
    <Box sx={{ minHeight: "100vh", py: { xs: 2, md: 3 } }}>
      <Container maxWidth="xl">
        <Stack
          component="header"
          direction="row"
          sx={{
            alignItems: "center",
            border: "1px solid rgba(148, 163, 184, 0.16)",
            borderRadius: 999,
            justifyContent: "space-between",
            px: { xs: 2, md: 3 },
            py: 1.25,
            bgcolor: "rgba(15, 23, 42, 0.64)",
            backdropFilter: "blur(20px)",
          }}
        >
          <Box
            component="a"
            href="/"
            sx={{ display: "flex", alignItems: "center", gap: 1.25 }}
          >
            <Box
              sx={{
                display: "grid",
                placeItems: "center",
                width: 36,
                height: 36,
                borderRadius: "50%",
                background: "linear-gradient(135deg, #22d3ee, #7c3aed)",
              }}
            >
              <AutoAwesomeIcon fontSize="small" />
            </Box>
            <Typography variant="h6" sx={{ fontWeight: 800, letterSpacing: "-0.04em" }}>
              Deep Faced
            </Typography>
          </Box>

          <Stack direction="row" spacing={1} sx={{ alignItems: "center" }}>
            <Button href="/faces" color="inherit">
              Faces
            </Button>
            <Button href="/upload" color="inherit">
              Upload
            </Button>
            <Button href="/videos" color="inherit">
              Videos
            </Button>
            <Button href="/download" color="inherit">
              Download
            </Button>
            <Button href="/download" variant="contained">
              Get the Mac App
            </Button>
          </Stack>
        </Stack>
        {children}
      </Container>
    </Box>
  );
}
