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
  },

  bootstrap() {},
};
