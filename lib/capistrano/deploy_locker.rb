
# Load recipe if required from deploy script
if defined?(Capistrano::Configuration) && Capistrano::Configuration.instance
  load File.expand_path("../tasks/deploy_locker.rake", __FILE__)
end

