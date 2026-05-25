export default ({ env }) => ({
  connection: {
    client: env('DATABASE_CLIENT', 'sqlite'),
    connection: {
      host: env('DATABASE_HOST', 'localhost'),
      port: env.int('DATABASE_PORT', 5432),
      database: env('DATABASE_NAME', 'strapi'),
      user: env('DATABASE_USERNAME', 'strapi'),
      password: env('DATABASE_PASSWORD', 'strapi'),
      ssl: env.bool('DATABASE_SSL', false),
      schema: env('DATABASE_SCHEMA', 'public'),
      filename: env('DATABASE_FILENAME', '.tmp/data.db'),
    },
    pool: {
      // min: 0 is required in Docker — a higher value causes connection issues on startup
      min: env.int('DATABASE_POOL_MIN', 0),
      max: env.int('DATABASE_POOL_MAX', 10),
      acquireTimeoutMillis: 60000,
      idleTimeoutMillis: 30000,
    },
    useNullAsDefault: true,
  },
});
