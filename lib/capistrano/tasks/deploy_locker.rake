
require 'capistrano/deploy_locker/helpers'
require 'capistrano/deploy_locker/lock'
require 'capistrano/deploy_locker/lock_manager'
require 'capistrano/deploy_locker/version'
require 'capistrano/dsl/deploy_locker'

include Capistrano::DeployLocker::Helpers
include Capistrano::DSL::DeployLocker

namespace :deploy_locker do

  def lock_manager
    @lock_manager ||= Capistrano::DeployLocker::LockManager.new(
      key: redis_key,
      expiration: deploy_locker_expiration,
      redis: load_redis
    )
  end

  desc "Check for a deploy lock. If present, deploy is aborted and message is displayed."
  task :check_lock do
    puts deploy_locker_check_message
    lock = lock_manager.locked?

    # next if no lock is held...
    (puts deploy_locker_no_lock_message; next) unless lock

    # check if the deploy user is the lock owner.
    # if they are, give them a countdown so they can CTRL-C
    # out of the deploy if they want...
    if lock.owner == local_user
      5.downto(1) do |i|
        Kernel.print deploy_locker_owner_message(i)
        sleep 1
      end
      puts
    else
      abort(deploy_locker_abort_message(lock))
    end
  end

  desc "Creates a lock so that other simultaneous deploys will be blocked"
  task :create_lock do
    lock = lock_manager.locked?

    # next if we've already got a lock...
    next if lock

    result = lock_manager.lock(local_user, "Deploying #{fetch(:branch)} branch")
    puts deploy_locker_create_message

    if !result && (lock = lock_manager.locked?)
      abort(deploy_locker_abort_message(lock))
    end
  end

  desc "Removes any existing lock that the deploying user holds so that other deploys can occur"
  task :remove_lock do
    lock = lock_manager.locked?

    if lock != nil && lock.owner == local_user
      puts deploy_locker_clear_message
      lock_manager.clear
    else
      abort(deploy_locker_abort_message(lock))
    end
  end

  desc "Removes any existing lock (regardless of owner) so that other deploys can occur"
  task :destroy_lock do
    puts deploy_locker_clear_message
    lock_manager.clear
  end

  before "deploy:starting", "deploy_locker:check_lock"
  before "deploy:starting", "deploy_locker:create_lock"
  before "deploy:finishing", "deploy_locker:remove_lock"
  after  "deploy:failed", "deploy_locker:remove_lock"
end

namespace :load do
  task :defaults do
    set :deploy_locker_key_prefix, "capistrano:deploy_locker"
    set :deploy_locker_expiration, 20 * 60 # 20 minutes
    set :deploy_locker_redis_config_file, "config/redis.yml"
  end
end

