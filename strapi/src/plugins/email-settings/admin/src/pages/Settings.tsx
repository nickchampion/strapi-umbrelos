import React, { useEffect, useState } from 'react';
import {
  Box,
  Button,
  Field,
  Flex,
  Grid,
  Loader,
  TextInput,
  Typography,
} from '@strapi/design-system';
import { Check, Mail } from '@strapi/icons';
import { useFetchClient, useNotification } from '@strapi/strapi/admin';

interface SmtpForm {
  host: string;
  port: string;
  username: string;
  password: string;
  from: string;
  replyTo: string;
}

const EMPTY: SmtpForm = {
  host: '',
  port: '587',
  username: '',
  password: '',
  from: '',
  replyTo: '',
};

export const Settings = () => {
  const [form, setForm] = useState<SmtpForm>(EMPTY);
  const [hasPassword, setHasPassword] = useState(false);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [testEmail, setTestEmail] = useState('');
  const [testing, setTesting] = useState(false);

  const { get, put, post } = useFetchClient();
  const { toggleNotification } = useNotification();

  useEffect(() => {
    get('/email-settings/settings')
      .then(({ data }: any) => {
        if (data?.data) {
          const { hasPassword: hp, ...rest } = data.data;
          setForm({ ...EMPTY, ...rest, password: '' });
          setHasPassword(hp);
        }
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const setField =
    (field: keyof SmtpForm) => (e: React.ChangeEvent<HTMLInputElement>) =>
      setForm((prev) => ({ ...prev, [field]: e.target.value }));

  const handleSave = async () => {
    setSaving(true);
    try {
      const { data }: any = await put('/email-settings/settings', form);
      if (data?.data) {
        setHasPassword(data.data.hasPassword);
        setForm((prev) => ({ ...prev, password: '' }));
      }
      toggleNotification({ type: 'success', message: 'Email settings saved.' });
    } catch {
      toggleNotification({ type: 'warning', message: 'Failed to save settings.' });
    } finally {
      setSaving(false);
    }
  };

  const handleTest = async () => {
    if (!testEmail) return;
    setTesting(true);
    try {
      const { data }: any = await post('/email-settings/test', { to: testEmail });
      if (data?.data?.success) {
        toggleNotification({ type: 'success', message: `Test email sent to ${testEmail}.` });
      } else {
        toggleNotification({
          type: 'warning',
          message: data?.data?.error ?? 'Failed to send test email.',
        });
      }
    } catch {
      toggleNotification({ type: 'warning', message: 'Failed to send test email.' });
    } finally {
      setTesting(false);
    }
  };

  if (loading) {
    return (
      <Box padding={8}>
        <Loader>Loading email settings…</Loader>
      </Box>
    );
  }

  return (
    <Box padding={8} background="neutral100">
      <Box paddingBottom={6}>
        <Typography variant="alpha" as="h1">
          Email Configuration
        </Typography>
        <Box paddingTop={1}>
          <Typography variant="epsilon" textColor="neutral600">
            Configure outbound email for password resets and notifications.
          </Typography>
        </Box>
      </Box>

      {/* SMTP settings */}
      <Box background="neutral0" padding={6} shadow="filterShadow" borderRadius="4px">
        <Box paddingBottom={4}>
          <Typography variant="delta" as="h2">
            SMTP Settings
          </Typography>
        </Box>

        <Grid.Root gap={5}>
          <Grid.Item col={8} s={12}>
            <Field.Root name="host" required>
              <Field.Label>Host</Field.Label>
              <TextInput
                placeholder="smtp.resend.com"
                value={form.host}
                onChange={setField('host')}
              />
            </Field.Root>
          </Grid.Item>

          <Grid.Item col={4} s={12}>
            <Field.Root name="port">
              <Field.Label>Port</Field.Label>
              <TextInput placeholder="587" value={form.port} onChange={setField('port')} />
            </Field.Root>
          </Grid.Item>

          <Grid.Item col={6} s={12}>
            <Field.Root name="username">
              <Field.Label>Username</Field.Label>
              <TextInput
                placeholder="resend"
                value={form.username}
                onChange={setField('username')}
              />
            </Field.Root>
          </Grid.Item>

          <Grid.Item col={6} s={12}>
            <Field.Root name="password">
              <Field.Label>
                Password
                {hasPassword && !form.password && (
                  <Typography textColor="neutral500"> — configured, leave blank to keep</Typography>
                )}
              </Field.Label>
              <TextInput
                type="password"
                placeholder={hasPassword ? '••••••••' : 'API key or password'}
                value={form.password}
                onChange={setField('password')}
              />
            </Field.Root>
          </Grid.Item>

          <Grid.Item col={6} s={12}>
            <Field.Root name="from">
              <Field.Label>From Address</Field.Label>
              <TextInput
                placeholder="hello@example.com"
                value={form.from}
                onChange={setField('from')}
              />
            </Field.Root>
          </Grid.Item>

          <Grid.Item col={6} s={12}>
            <Field.Root name="replyTo">
              <Field.Label>Reply-To Address</Field.Label>
              <TextInput
                placeholder="hello@example.com"
                value={form.replyTo}
                onChange={setField('replyTo')}
              />
            </Field.Root>
          </Grid.Item>
        </Grid.Root>

        <Box paddingTop={5}>
          <Button onClick={handleSave} loading={saving} startIcon={<Check />}>
            Save
          </Button>
        </Box>
      </Box>

      {/* Test email */}
      <Box
        background="neutral0"
        padding={6}
        shadow="filterShadow"
        borderRadius="4px"
        marginTop={4}
      >
        <Box paddingBottom={4}>
          <Typography variant="delta" as="h2">
            Test Email
          </Typography>
          <Box paddingTop={1}>
            <Typography variant="omega" textColor="neutral600">
              Send a test message to verify your configuration.
            </Typography>
          </Box>
        </Box>

        <Flex gap={4} alignItems="flex-end">
          <Box flex="1">
            <Field.Root name="testEmail">
              <Field.Label>Send test to</Field.Label>
              <TextInput
                placeholder="you@example.com"
                value={testEmail}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setTestEmail(e.target.value)}
              />
            </Field.Root>
          </Box>
          <Button
            variant="secondary"
            onClick={handleTest}
            loading={testing}
            disabled={!testEmail}
            startIcon={<Mail />}
          >
            Send
          </Button>
        </Flex>
      </Box>
    </Box>
  );
};
