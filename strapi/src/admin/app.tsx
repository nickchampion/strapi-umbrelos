import type { StrapiApp } from '@strapi/strapi/admin';

export default {
  register(app: StrapiApp) {
    app.addSettingsLink('global', {
      intlLabel: { id: 'email-settings.nav.label', defaultMessage: 'Email' },
      id: 'email-settings',
      to: '/settings/email-settings',
      Component: async () => {
        const { Settings } = await import('./pages/EmailSettings');
        return { default: Settings };
      },
      permissions: [],
    });

    app.addSettingsLink('global', {
      intlLabel: { id: 'run-mode.nav.label', defaultMessage: 'Run Mode' },
      id: 'run-mode',
      to: '/settings/run-mode',
      Component: async () => {
        const { Settings } = await import('./pages/RunModeSettings');
        return { default: Settings };
      },
      permissions: [],
    });
  },

  bootstrap() {},
};
