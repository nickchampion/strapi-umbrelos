import controllers from './controllers';
import routes from './routes';
import services from './services';

export default {
  register({ strapi }: { strapi: any }) {},

  async bootstrap({ strapi }: { strapi: any }) {
    // Apply any stored SMTP settings on startup so email works immediately
    // without needing a settings save from the UI on first boot.
    const settings = await services.getSettings(strapi);
    if (settings?.host) {
      services.applyToEmailPlugin(strapi, settings);
    }
  },

  controllers: {
    settings: controllers,
  },

  routes,

  services: {
    settings: () => services,
  },
};
