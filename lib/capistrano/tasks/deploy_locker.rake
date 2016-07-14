
require "capistrano/dsl/deploy_locker"
require "capistrano/deploy_locker/helpers"
require "capistrano/deploy_locker/lock"
require "capistrano/deploy_locker/lock_manager"
require "capistrano/deploy_locker/version"

include Capistrano::DeployLocker::Helpers
include Capistrano::DSL::DeployLocker

DEPLOY_LOCKER_ABORT_MESSAGE = "Deploy is locked by %s (expires at %s). Aborting...".freeze
DEPLOY_LOCKER_OWNER_MESSAGE = "\rDeploy lock is owned by you (%s). Continuing deploy in %s...".freeze

LockManager.configure(
  key: deploy_locker_key,
  expiration: deploy_locker_expiration
)

namespace :deploy_locker do
  desc "Check for a deploy lock. If present, deploy is aborted and message is displayed."
  task :check_lock do
    lock = LockManager.locked?

    # next if no lock is held...
    next if lock.nil?

    # check if the deploy user is the lock owner.
    # if they are, give them a countdown so they can CTRL-C
    # out of the deploy if they want...
    if lock.owner == deploy_user
      5.downto(1) do |i|
        Kernel.print (DEPLOY_LOCKER_OWNER_MESSAGE % [deploy_user, i])
        sleep 1
      end
    else
      abort(DEPLOY_LOCKER_ABORT_MESSAGE % [lock.owner, Time.at(lock.expiration)])
    end
  end

  desc "Creates a lock so that other simultaneous deploys will be blocked"
  task :create_lock do
    lock = LockManager.locked?

    # next if we've already got a lock...
    next unless lock.nil?

    result = LockManager.lock(deploy_user, "Deploying #{branch} branch")

    if !result && (lock = LockManager.locked?)
      abort(DEPLOY_LOCKER_ABORT_MESSAGE % [lock.owner, Time.at(lock.expiration)])
    end
  end

  desc "Removes any existing lock so that other deploys can occur"
  task :remove_lock do
    LockManager.clear
  end

  before "deploy:updating", "deploy_locker:check_lock"
  before "deploy:updating", "deploy_locker:create_lock"
  after  "deploy:finished", "deploy_locker:remove_lock"
end

