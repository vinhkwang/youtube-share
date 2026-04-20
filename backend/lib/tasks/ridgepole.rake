namespace :ridgepole do
  def ridgepole_connection_url
    cfg = ActiveRecord::Base.configurations.find_db_config(Rails.env).configuration_hash
    host     = cfg[:host]     || ENV.fetch("DB_HOST", "localhost")
    port     = cfg[:port]     || ENV.fetch("DB_PORT", 5432)
    username = cfg[:username] || ENV.fetch("DB_USERNAME", "postgres")
    password = cfg[:password] || ENV.fetch("DB_PASSWORD", "")
    database = cfg[:database] || ENV.fetch("DB_NAME", "youtube_sharing_development")
    adapter  = cfg[:adapter]  || "postgresql"

    "#{adapter}://#{username}:#{password}@#{host}:#{port}/#{database}"
  end

  def ridgepole_base_cmd
    "bundle exec ridgepole --config #{ridgepole_connection_url} --file db/Schemafile"
  end

  desc "Apply db/Schemafile to the #{Rails.env} database"
  task apply: :environment do
    cmd = "#{ridgepole_base_cmd} --apply"
    puts "Running: #{cmd}"
    system(cmd) || abort("ridgepole:apply failed")
  end

  desc "Dry-run — show what ridgepole would change without touching the DB"
  task dry_run: :environment do
    cmd = "#{ridgepole_base_cmd} --apply --dry-run"
    puts "Running: #{cmd}"
    system(cmd) || abort("ridgepole:dry_run failed")
  end

  desc "Export current DB schema to Schemafile format (stdout)"
  task export: :environment do
    cmd = "#{ridgepole_base_cmd} --export"
    puts "Running: #{cmd}"
    system(cmd) || abort("ridgepole:export failed")
  end

  desc "Create DB then apply Schemafile (first-time setup)"
  task apply_all: :environment do
    Rake::Task["db:create"].invoke
    Rake::Task["ridgepole:apply"].invoke
  end
end
