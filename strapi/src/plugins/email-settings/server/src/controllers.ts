export default ({ strapi }: { strapi: any }) => ({
  async find(ctx: any) {
    const settings = await strapi
      .plugin('email-settings')
      .service('settings')
      .getSettings(strapi);

    if (!settings) {
      ctx.body = { data: null };
      return;
    }

    const { password, ...safe } = settings;
    ctx.body = { data: { ...safe, hasPassword: !!password } };
  },

  async update(ctx: any) {
    const body = ctx.request.body?.data ?? ctx.request.body ?? {};

    const settings = await strapi
      .plugin('email-settings')
      .service('settings')
      .saveSettings(strapi, body);

    strapi
      .plugin('email-settings')
      .service('settings')
      .applyToEmailPlugin(strapi, settings);

    const { password, ...safe } = settings;
    ctx.body = { data: { ...safe, hasPassword: !!password } };
  },

  async test(ctx: any) {
    const body = ctx.request.body?.data ?? ctx.request.body ?? {};
    const { to } = body;

    if (!to) {
      ctx.status = 400;
      ctx.body = { error: 'Missing "to" address' };
      return;
    }

    try {
      await strapi.plugin('email').service('email').send({
        to,
        subject: 'Strapi SMTP Test',
        html: '<p>Your Strapi email configuration is working correctly.</p>',
        text: 'Your Strapi email configuration is working correctly.',
      });
      ctx.body = { data: { success: true } };
    } catch (err: any) {
      ctx.status = 400;
      ctx.body = { data: { success: false, error: err.message } };
    }
  },
});
