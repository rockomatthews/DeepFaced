import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  transpilePackages: [
    "@deep-faced/ar-engine",
    "@deep-faced/effects",
    "@deep-faced/shared",
  ],
};

export default nextConfig;
