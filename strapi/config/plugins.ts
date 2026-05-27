import type { Core } from '@strapi/strapi';

const config = ({ env }: Core.Config.Shared.ConfigParams): Core.Config.Plugin => ({
  // Nodemailer provider initialised with env vars as fallback.
  // The email-settings plugin overrides the send method at bootstrap
  // with whatever the admin has saved in Settings → Email.
  email: {
    config: {
      provider: 'nodemailer',
      providerOptions: {
        host: env('SMTP_HOST', ''),
        port: env.int('SMTP_PORT', 587),
        auth: {
          user: env('SMTP_USERNAME', ''),
          pass: env('SMTP_PASSWORD', ''),
        },
      },
      settings: {
        defaultFrom: env('SMTP_FROM', ''),
        defaultReplyTo: env('SMTP_REPLY_TO', ''),
      },
    },
  },

  'email-settings': {
    enabled: true,
    // Point at the compiled dist/ — TypeScript copies package.json there via src/**/*.json include
    resolve: './dist/src/plugins/email-settings',
  },

  'run-mode': {
    enabled: true,
    resolve: './dist/src/plugins/run-mode',
  },
});

export default config;
