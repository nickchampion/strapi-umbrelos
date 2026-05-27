import { mergeConfig, type UserConfig } from 'vite';

export default (config: UserConfig) => {
  return mergeConfig(config, {
    server: {
      // Allow any hostname so the admin panel is accessible via custom
      // domains, Cloudflare tunnels, VPNs, etc.
      allowedHosts: true,
      // Disable HMR — the app is behind a proxy (UmbrelOS forwards port 1337
      // only), so Vite's WebSocket on port 5173 is unreachable. Constant
      // reconnect attempts break React context and cause useContext errors.
      hmr: false,
    },
  });
};
