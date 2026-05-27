export default [
  {
    method: 'GET',
    path: '/mode',
    handler: 'run-mode.find',
    config: { policies: [] },
  },
  {
    method: 'POST',
    path: '/mode',
    handler: 'run-mode.update',
    config: { policies: [] },
  },
]