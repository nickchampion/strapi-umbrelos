import { mergeConfig, type UserConfig } from 'vite';

export default (config: UserConfig) => {
  return mergeConfig(config, {
    server: {
      // Allow any hostname so the admin panel is accessible via custom
      // domains, Cloudflare tunnels, VPNs, etc.
      allowedHosts: true,
    },
  });
};
