import type { NextConfig } from 'next';

// PWA Configuration with Docker build optimization
const withPWA = require('next-pwa')({
  dest: 'public',
  register: true,
  skipWaiting: true,
  disable: process.env.NODE_ENV === 'development' || process.env.DISABLE_PWA_BUILD === 'true',
  // Optimize service worker generation for Docker builds
  sw: '/sw.js',
  fallbacks: {
    document: '/offline.html',
  },
  // Reduce CPU usage during build
  disableDevLogs: true,
  maximumFileSizeToCacheInBytes: 5 * 1024 * 1024, // 5MB limit
  exclude: [
    /\.map$/,
    /manifest$/,
    /\.DS_Store$/,
    /^\/admin/,
    /^\/api/,
    /chunks\/.*\.js$/,
  ],
  runtimeCaching: [
    {
      urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
      handler: 'CacheFirst',
      options: {
        cacheName: 'google-fonts',
        expiration: {
          maxEntries: 4,
          maxAgeSeconds: 365 * 24 * 60 * 60, // 365 days
        },
      },
    },
    {
      urlPattern: /\.(?:png|jpg|jpeg|svg|gif|webp)$/i,
      handler: 'StaleWhileRevalidate',
      options: {
        cacheName: 'static-image-assets',
        expiration: {
          maxEntries: 64,
          maxAgeSeconds: 24 * 60 * 60, // 24 hours
        },
      },
    },
  ],
});

const nextConfig: NextConfig = {
  // Use standalone output for Docker builds and memory-optimized builds
  ...(process.env.DOCKER_BUILD === 'true' || process.env.BUILD_SITE_ONLY === 'true' || process.env.STANDALONE_BUILD === 'true' ? { output: 'standalone' } : {}),
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: process.env.NODE_ENV === 'production',
  },
  // Fix routes manifest issue by explicitly defining rewrites structure
  async rewrites() {
    return {
      beforeFiles: [],
      afterFiles: [],
      fallback: [],
    };
  },
  // Configure headers to prevent caching issues
  async headers() {
    return [
      {
        source: '/_next/static/(.*)',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
        ],
      },
      {
        source: '/sw.js',
        headers: [
          {
            key: 'Cache-Control',
            value: 'public, max-age=0, must-revalidate',
          },
        ],
      },
    ];
  },
  // Webpack configuration to handle module resolution issues and Docker optimization
  webpack: (config, { dev, isServer }) => {
    // Handle SVG files
    config.module.rules.push({
      test: /\.svg$/,
      use: ['@svgr/webpack'],
    });

    // Resolve module issues that can cause routes manifest problems
    config.resolve.fallback = {
      ...config.resolve.fallback,
      fs: false,
      net: false,
      tls: false,
    };

    // Optimize for Docker builds - reduce memory usage
    if (process.env.DOCKER_BUILD === 'true') {
      config.optimization = {
        ...config.optimization,
        usedExports: true,
        sideEffects: false,
        minimize: true,
      };

      // Limit worker threads for Docker environment
      config.parallelism = 1;
      
      // Reduce memory usage during build
      config.performance = {
        hints: false,
        maxEntrypointSize: 512000,
        maxAssetSize: 512000,
      };
    }

    return config;
  },
};

// Export with or without PWA depending on environment and Docker build
export default (process.env.NODE_ENV === 'development' || process.env.DISABLE_PWA_BUILD === 'true')
  ? nextConfig 
  : withPWA(nextConfig);
