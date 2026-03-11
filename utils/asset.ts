export const getAssetUrl = (path: string) => {
  const basePath = process.env.NEXT_PUBLIC_BASE_PATH || '';
  // Avoid double slashes if path also starts with /
  if (path.startsWith('/') && basePath.endsWith('/')) {
    return `${basePath}${path.substring(1)}`;
  }
  if (!path.startsWith('/') && !basePath.endsWith('/')) {
    return `${basePath}/${path}`;
  }
  return `${basePath}${path}`;
};
