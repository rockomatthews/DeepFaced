import type { DeepFacedEffect } from "@deep-faced/shared";
import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import Box from "@mui/material/Box";
import Card from "@mui/material/Card";
import CardActionArea from "@mui/material/CardActionArea";
import CardContent from "@mui/material/CardContent";
import Chip from "@mui/material/Chip";
import Stack from "@mui/material/Stack";
import Typography from "@mui/material/Typography";

type EffectCardProps = {
  effect: DeepFacedEffect;
  selected?: boolean;
  onSelect?: (effect: DeepFacedEffect) => void;
};

export function EffectCard({ effect, onSelect, selected = false }: EffectCardProps) {
  const content = (
    <>
      <Box
        sx={{
          height: 132,
          borderRadius: 3,
          background: effect.thumbnailGradient,
          border: "1px solid rgba(255,255,255,0.18)",
          mb: 2,
          position: "relative",
          overflow: "hidden",
        }}
      >
        <Box
          sx={{
            position: "absolute",
            inset: "20% 27%",
            borderRadius: "42% 42% 48% 48%",
            border: "2px solid rgba(255,255,255,0.58)",
            boxShadow: "0 0 38px rgba(255,255,255,0.28)",
          }}
        />
      </Box>
      <Stack direction="row" spacing={1} sx={{ alignItems: "center", justifyContent: "space-between" }}>
        <Typography variant="h6" sx={{ fontWeight: 800 }}>
          {effect.name}
        </Typography>
        {selected ? <CheckCircleIcon color="secondary" fontSize="small" /> : null}
      </Stack>
      <Typography color="text.secondary" variant="body2" sx={{ minHeight: 44 }}>
        {effect.description}
      </Typography>
      <Stack direction="row" spacing={1} useFlexGap sx={{ flexWrap: "wrap", mt: 2 }}>
        <Chip size="small" label={effect.category} />
        <Chip size="small" label={`${effect.performance.targetFps} fps`} />
      </Stack>
    </>
  );

  return (
    <Card
      sx={{
        height: "100%",
        outline: selected ? "2px solid" : "none",
        outlineColor: "secondary.main",
      }}
    >
      {onSelect ? (
        <CardActionArea onClick={() => onSelect(effect)} sx={{ height: "100%" }}>
          <CardContent>{content}</CardContent>
        </CardActionArea>
      ) : (
        <CardContent>{content}</CardContent>
      )}
    </Card>
  );
}
