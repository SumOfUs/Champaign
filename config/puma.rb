workers Integer(ENV['PUMA_WORKERS'] || 1)
threads_count = Integer(ENV['MAX_THREADS'] || 1)
threads 1, threads_count

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RAILS_ENV'] || 'development'

