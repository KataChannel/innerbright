import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'standalone',
  images: {
    unoptimized: true, // For better compatibility in Docker
  },
};

export default nextConfig;
