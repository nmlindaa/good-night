Rails.application.config.before_initialize do
  ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS "pgcrypto";')
end
