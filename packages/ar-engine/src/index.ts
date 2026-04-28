import type { DeepFacedEffect, EffectPreset } from "@deep-faced/shared";

export type DeepARSessionStatus =
  | "idle"
  | "camera-ready"
  | "simulated-deepar"
  | "stopped";

export type DeepARSessionOptions = {
  video: HTMLVideoElement;
  canvas: HTMLCanvasElement;
  effect: DeepFacedEffect;
  preset: EffectPreset;
};

export type DeepARSession = {
  status: DeepARSessionStatus;
  setEffect: (effect: DeepFacedEffect, preset: EffectPreset) => void;
  captureStream: (fps?: number) => MediaStream;
  stop: () => void;
};

export function createDeepARSession(options: DeepARSessionOptions): DeepARSession {
  return new CanvasDeepARSession(options);
}

class CanvasDeepARSession implements DeepARSession {
  status: DeepARSessionStatus = "idle";

  private animationFrame = 0;
  private effect: DeepFacedEffect;
  private preset: EffectPreset;
  private readonly video: HTMLVideoElement;
  private readonly canvas: HTMLCanvasElement;
  private readonly context: CanvasRenderingContext2D;

  constructor(options: DeepARSessionOptions) {
    const context = options.canvas.getContext("2d");

    if (!context) {
      throw new Error("DeepAR canvas rendering requires a 2D context.");
    }

    this.video = options.video;
    this.canvas = options.canvas;
    this.context = context;
    this.effect = options.effect;
    this.preset = options.preset;
    this.status = "camera-ready";
    this.start();
  }

  setEffect(effect: DeepFacedEffect, preset: EffectPreset) {
    this.effect = effect;
    this.preset = preset;
  }

  captureStream(fps = 30) {
    return this.canvas.captureStream(fps);
  }

  stop() {
    window.cancelAnimationFrame(this.animationFrame);
    this.status = "stopped";
  }

  private start() {
    this.status = "simulated-deepar";
    const draw = () => {
      this.renderFrame();
      this.animationFrame = window.requestAnimationFrame(draw);
    };

    draw();
  }

  private renderFrame() {
    const { width, height } = this.canvas;

    this.context.clearRect(0, 0, width, height);
    this.context.save();
    this.context.translate(width, 0);
    this.context.scale(-1, 1);

    if (this.video.readyState >= HTMLMediaElement.HAVE_CURRENT_DATA) {
      this.context.drawImage(this.video, 0, 0, width, height);
    } else {
      this.context.fillStyle = "#050816";
      this.context.fillRect(0, 0, width, height);
    }

    this.context.restore();
    this.drawPrototypeMask(width, height);
    this.drawStatusBadge();
  }

  private drawPrototypeMask(width: number, height: number) {
    const { accentHue, alignment, glow, intensity, scale } = this.preset.parameters;
    const centerX = width / 2;
    const centerY = height * 0.43 + alignment;
    const maskScale = scale / 100;
    const maskWidth = width * 0.3 * maskScale;
    const maskHeight = height * 0.42 * maskScale;
    const alpha = 0.18 + intensity / 180;
    const glowSize = 12 + glow * 0.45;

    this.context.save();
    this.context.shadowColor = `hsla(${accentHue}, 95%, 62%, ${0.25 + glow / 170})`;
    this.context.shadowBlur = glowSize;

    const gradient = this.context.createLinearGradient(
      centerX - maskWidth,
      centerY - maskHeight,
      centerX + maskWidth,
      centerY + maskHeight,
    );
    gradient.addColorStop(0, `hsla(${accentHue}, 95%, 62%, ${alpha})`);
    gradient.addColorStop(0.52, "rgba(9, 12, 28, 0.72)");
    gradient.addColorStop(1, `hsla(${(accentHue + 70) % 360}, 90%, 58%, ${alpha})`);

    this.context.fillStyle = gradient;
    this.roundedFacePlate(centerX, centerY, maskWidth, maskHeight);
    this.context.fill();

    this.context.lineWidth = Math.max(4, width * 0.006);
    this.context.strokeStyle = `hsla(${accentHue}, 95%, 68%, 0.78)`;
    this.context.stroke();

    this.drawEyes(centerX, centerY, maskWidth, accentHue);
    this.drawMouth(centerX, centerY, maskWidth, accentHue);
    this.drawEffectLabel(centerX, centerY + maskHeight / 2 + 44);
    this.context.restore();
  }

  private roundedFacePlate(
    centerX: number,
    centerY: number,
    maskWidth: number,
    maskHeight: number,
  ) {
    const x = centerX - maskWidth / 2;
    const y = centerY - maskHeight / 2;
    const radius = maskWidth * 0.22;

    this.context.beginPath();
    this.context.moveTo(x + radius, y);
    this.context.quadraticCurveTo(x + maskWidth, y, x + maskWidth, y + radius);
    this.context.quadraticCurveTo(
      x + maskWidth * 0.94,
      y + maskHeight,
      centerX,
      y + maskHeight,
    );
    this.context.quadraticCurveTo(x + maskWidth * 0.06, y + maskHeight, x, y + radius);
    this.context.quadraticCurveTo(x, y, x + radius, y);
    this.context.closePath();
  }

  private drawEyes(centerX: number, centerY: number, maskWidth: number, hue: number) {
    this.context.fillStyle = `hsla(${hue}, 100%, 72%, 0.9)`;
    this.context.beginPath();
    this.context.ellipse(centerX - maskWidth * 0.18, centerY - 20, 44, 17, -0.12, 0, Math.PI * 2);
    this.context.ellipse(centerX + maskWidth * 0.18, centerY - 20, 44, 17, 0.12, 0, Math.PI * 2);
    this.context.fill();
  }

  private drawMouth(centerX: number, centerY: number, maskWidth: number, hue: number) {
    this.context.strokeStyle = `hsla(${hue}, 100%, 74%, 0.78)`;
    this.context.lineWidth = 5;
    this.context.beginPath();
    this.context.moveTo(centerX - maskWidth * 0.17, centerY + 74);
    this.context.quadraticCurveTo(centerX, centerY + 96, centerX + maskWidth * 0.17, centerY + 74);
    this.context.stroke();
  }

  private drawEffectLabel(centerX: number, y: number) {
    this.context.font = "600 22px Arial";
    this.context.textAlign = "center";
    this.context.fillStyle = "rgba(255, 255, 255, 0.88)";
    this.context.fillText(this.effect.name, centerX, y);
  }

  private drawStatusBadge() {
    this.context.save();
    this.context.font = "600 16px Arial";
    this.context.fillStyle = "rgba(5, 8, 22, 0.72)";
    this.context.fillRect(24, 24, 250, 36);
    this.context.fillStyle = "rgba(255, 255, 255, 0.82)";
    this.context.fillText("DeepAR adapter: prototype renderer", 40, 48);
    this.context.restore();
  }
}
