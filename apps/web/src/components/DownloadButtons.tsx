import AppleIcon from "@mui/icons-material/Apple";
import PhoneIphoneIcon from "@mui/icons-material/PhoneIphone";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";
import { desktopReleases } from "@/data/downloads";

export function DownloadButtons() {
  return (
    <Stack direction={{ xs: "column", sm: "row" }} spacing={1.5}>
      {desktopReleases.map((release) => (
        <Button
          key={release.id}
          href={release.href}
          size="large"
          variant={release.platform === "macos" ? "contained" : "outlined"}
          startIcon={release.platform === "macos" ? <AppleIcon /> : <PhoneIphoneIcon />}
        >
          <span>
            {release.label}
            <Typography component="span" variant="caption" sx={{ display: "block", opacity: 0.78 }}>
              {release.version}
            </Typography>
          </span>
        </Button>
      ))}
    </Stack>
  );
}
