import { createTheme } from "@mui/material/styles";

export const theme = createTheme({
  colorSchemes: {
    dark: true,
  },
  palette: {
    mode: "dark",
    primary: {
      main: "#7c3aed",
    },
    secondary: {
      main: "#22d3ee",
    },
    background: {
      default: "#050816",
      paper: "rgba(15, 23, 42, 0.86)",
    },
  },
  shape: {
    borderRadius: 18,
  },
  typography: {
    fontFamily: "var(--font-geist-sans), Arial, sans-serif",
    h1: {
      fontWeight: 800,
      letterSpacing: "-0.06em",
    },
    h2: {
      fontWeight: 800,
      letterSpacing: "-0.045em",
    },
    h3: {
      fontWeight: 700,
      letterSpacing: "-0.03em",
    },
    button: {
      fontWeight: 700,
      textTransform: "none",
    },
  },
  components: {
    MuiCard: {
      styleOverrides: {
        root: {
          border: "1px solid rgba(148, 163, 184, 0.18)",
          backgroundImage:
            "linear-gradient(145deg, rgba(15, 23, 42, 0.92), rgba(15, 23, 42, 0.62))",
          backdropFilter: "blur(18px)",
        },
      },
    },
    MuiButton: {
      defaultProps: {
        disableElevation: true,
      },
      styleOverrides: {
        root: {
          borderRadius: 999,
        },
      },
    },
  },
});
