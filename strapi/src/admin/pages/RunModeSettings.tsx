import React, { useEffect, useState } from 'react';
import { Box, Button, Flex, Loader, Typography } from '@strapi/design-system';
import { useFetchClient, useNotification } from '@strapi/strapi/admin';

type Mode = 'development' | 'production';

const MODES: { value: Mode; label: string; description: string }[] = [
  {
    value: 'development',
    label: 'Content Editing',
    description:
      'Content types can be created and modified. Vite dev server runs alongside Strapi. Use this when building your schema.',
  },
  {
    value: 'production',
    label: 'Production',
    description:
      'Serves content via a fast, read-only server. Content types cannot be modified. Recommended once your schema is stable.',
  },
];

export const Settings = () => {
  const [currentMode, setCurrentMode] = useState<Mode>('development');
  const [selectedMode, setSelectedMode] = useState<Mode>('development');
  const [loading, setLoading] = useState(true);
  const [switching, setSwitching] = useState(false);
  const [restarting, setRestarting] = useState(false);

  const { get, post } = useFetchClient();
  const { toggleNotification } = useNotification();

  useEffect(() => {
    get('/api/run-mode/mode')
      .then(({ data }: any) => {
        const mode: Mode = data?.data?.mode === 'production' ? 'production' : 'development';
        setCurrentMode(mode);
        setSelectedMode(mode);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const handleApply = async () => {
    setSwitching(true);
    try {
      await post('/api/run-mode/mode', { data: { mode: selectedMode } });
      setRestarting(true);
    } catch {
      toggleNotification({ type: 'warning', message: 'Failed to switch mode.' });
      setSwitching(false);
    }
  };

  if (loading) {
    return (
      <Box padding={8}>
        <Loader>Loading…</Loader>
      </Box>
    );
  }

  if (restarting) {
    return (
      <Box padding={8} background="neutral100">
        <Box
          background="neutral0"
          padding={8}
          shadow="filterShadow"
          borderRadius="4px"
          style={{ maxWidth: 560 }}
        >
          <Flex direction="column" alignItems="flex-start" gap={4}>
            <Loader>Restarting Strapi…</Loader>
            <Typography variant="omega" textColor="neutral600">
              Strapi is restarting in{' '}
              <strong>{selectedMode === 'production' ? 'production' : 'content editing'}</strong>{' '}
              mode. This takes approximately 60 seconds.
            </Typography>
            <Typography variant="omega" textColor="neutral600">
              Refresh this page once Strapi is back.
            </Typography>
          </Flex>
        </Box>
      </Box>
    );
  }

  return (
    <Box padding={8} background="neutral100">
      <Box paddingBottom={6}>
        <Typography variant="alpha" as="h1">
          Run Mode
        </Typography>
        <Box paddingTop={1}>
          <Typography variant="epsilon" textColor="neutral600">
            Switch between content editing and production modes. Changing mode restarts Strapi.
          </Typography>
        </Box>
      </Box>

      <Flex direction="column" gap={3} style={{ maxWidth: 560 }}>
        {MODES.map(({ value, label, description }) => {
          const isSelected = selectedMode === value;
          const isCurrent = currentMode === value;
          return (
            <Box
              key={value}
              background="neutral0"
              padding={5}
              shadow="filterShadow"
              borderRadius="4px"
              style={{
                cursor: 'pointer',
                border: `2px solid ${isSelected ? '#4945ff' : '#dcdce4'}`,
                transition: 'border-color 0.15s',
              }}
              onClick={() => setSelectedMode(value)}
            >
              <Flex justifyContent="space-between" alignItems="flex-start">
                <Flex direction="column" alignItems="flex-start" gap={1}>
                  <Flex gap={2} alignItems="center">
                    <Typography variant="delta" style={{ color: isSelected ? '#4945ff' : 'inherit' }}>
                      {label}
                    </Typography>
                    {isCurrent && (
                      <Box
                        background="success100"
                        paddingLeft={2}
                        paddingRight={2}
                        paddingTop={1}
                        paddingBottom={1}
                        borderRadius="4px"
                      >
                        <Typography variant="sigma" textColor="success600">
                          ACTIVE
                        </Typography>
                      </Box>
                    )}
                  </Flex>
                  <Typography variant="omega" textColor="neutral600">
                    {description}
                  </Typography>
                </Flex>
                <Box
                  style={{
                    width: 20,
                    height: 20,
                    borderRadius: '50%',
                    border: `2px solid ${isSelected ? '#4945ff' : '#c0c0cf'}`,
                    background: isSelected ? '#4945ff' : 'transparent',
                    flexShrink: 0,
                    marginLeft: 12,
                    marginTop: 2,
                  }}
                />
              </Flex>
            </Box>
          );
        })}
      </Flex>

      <Box paddingTop={5}>
        <Flex gap={4} alignItems="center">
          <Button
            onClick={handleApply}
            loading={switching}
            disabled={selectedMode === currentMode}
          >
            Apply &amp; Restart
          </Button>
          {selectedMode !== currentMode && (
            <Typography variant="omega" textColor="neutral500">
              ⚠️ Strapi will restart — approx. 60 seconds of downtime
            </Typography>
          )}
        </Flex>
      </Box>
    </Box>
  );
};
