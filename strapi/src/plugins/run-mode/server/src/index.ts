import controllers from './controllers';
import routes from './routes';

export default {
  register({ strapi }: { strapi: any }) {},
  bootstrap({ strapi }: { strapi: any }) {},

  controllers: {
    'run-mode': controllers,
  },

  routes,
};
