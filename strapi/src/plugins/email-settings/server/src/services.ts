import nodemailer from 'nodemailer';

export interface SmtpSettings {
  host: string;
  port: number;
  username: string;
  password: string;
  from: string;
  replyTo: string;
}

const STORE_KEY = 'smtp';
const PLUGIN_NAME = 'email-settings';

function getStore(strapi: any) {
  return strapi.store({ type: 'plugin', name: PLUGIN_NAME });
}

async function getSettings(strapi: any): Promise<SmtpSettings | null> {
  return getStore(strapi).get({ key: STORE_KEY });
}

async function saveSettings(strapi: any, incoming: Partial<SmtpSettings>): Promise<SmtpSettings> {
  const existing: Partial<SmtpSettings> = (await getSettings(strapi)) ?? {};
  const merged: SmtpSettings = {
    host: incoming.host ?? existing.host ?? '',
    port: Number(incoming.port ?? existing.port ?? 587),
    username: incoming.username ?? existing.username ?? '',
    // Keep existing password when incoming is blank
    password: incoming.password || existing.password || '',
    from: incoming.from ?? existing.from ?? '',
    replyTo: incoming.replyTo ?? existing.replyTo ?? '',
  };
  await getStore(strapi).set({ key: STORE_KEY, value: merged });
  return merged;
}

function applyToEmailPlugin(strapi: any, settings: SmtpSettings) {
  if (!settings?.host) return;

  const emailPlugin = strapi.plugin('email');
  if (!emailPlugin) return;

  const transporter = nodemailer.createTransport({
    host: settings.host,
    port: Number(settings.port) || 587,
    secure: Number(settings.port) === 465,
    auth: settings.username
      ? { user: settings.username, pass: settings.password }
      : undefined,
  });

  // Override the email service send method so DB settings take effect immediately
  // without requiring an env var change or container restart.
  const emailService = emailPlugin.service('email');
  emailService.send = async (options: any) => {
    const from = settings.from || settings.username;
    return transporter.sendMail({
      from,
      replyTo: settings.replyTo || from,
      ...options,
    });
  };
}

export default { getSettings, saveSettings, applyToEmailPlugin };
