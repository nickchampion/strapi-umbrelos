export default {
  admin: {
    routes: [
      {
        method: 'GET',
        path: '/settings',
        handler: 'settings.find',
        config: { policies: [] },
      },
      {
        method: 'PUT',
        path: '/settings',
        handler: 'settings.update',
        config: { policies: [] },
      },
      {
        method: 'POST',
        path: '/test',
        handler: 'settings.test',
        config: { policies: [] },
      },
    ],
  },
};
