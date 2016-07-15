require 'yaml'

module Capistrano
  module DeployLocker
    module Helpers

      DEPLOY_LOCKER_LOCK_MESSAGE    = "Deploying '%s' branch".freeze
      DEPLOY_LOCKER_CHECK_MESSAGE   = "[\e[32mDeployLocker\e[0m] Checking for a deploy lock on '%s'".freeze
      DEPLOY_LOCKER_NO_LOCK_MESSAGE = "[\e[32mDeployLocker\e[0m] No deploy lock is currently held, continuing...".freeze
      DEPLOY_LOCKER_CLEAR_MESSAGE   = "[\e[32mDeployLocker\e[0m] Removing deploy lock on '%s'".freeze
      DEPLOY_LOCKER_ABORT_MESSAGE   = "[\e[31mDeployLocker\e[0m] Aborting! Deploy is locked by %s (expires at %s). Run deploy_locker:destroy_lock task to manually clear lock...".freeze
      DEPLOY_LOCKER_CREATE_MESSAGE  = "[\e[32mDeployLocker\e[0m] Obtaining deploy lock for user '%s' on '%s' for %s seconds".freeze
      DEPLOY_LOCKER_OWNER_MESSAGE   = "\r[\e[32mDeployLocker\e[0m] Deploy lock is owned by you (%s). Continuing deploy in %s (hit CTRL-C to abort)...".freeze

      def deploy_locker_check_message
        DEPLOY_LOCKER_CHECK_MESSAGE % redis_key
      end

      def deploy_locker_create_message
        DEPLOY_LOCKER_CREATE_MESSAGE % [local_user, redis_key, fetch(:deploy_locker_expiration)]
      end

      def deploy_locker_clear_message
        DEPLOY_LOCKER_CLEAR_MESSAGE % redis_key
      end

      def deploy_locker_abort_message(lock)
        DEPLOY_LOCKER_ABORT_MESSAGE % [lock.owner, lock.expiration]
      end

      def deploy_locker_owner_message(count)
        DEPLOY_LOCKER_OWNER_MESSAGE % [local_user, count]
      end

      def deploy_locker_no_lock_message
        DEPLOY_LOCKER_NO_LOCK_MESSAGE
      end

      def deploy_locker_lock_message
        DEPLOY_LOCKER_LOCK_MESSAGE % fetch(:branch)
      end

      def local_user
        @local_user ||= `id -un`.chomp
      end

      def redis_key
        [fetch(:deploy_locker_key_prefix), fetch(:application), fetch(:stage)].join(":")
      end

      def load_redis
        config_path = fetch(:deploy_locker_redis_config_file)
        stage = fetch(:stage)

        raise ArgumentError, "Redis config file '#{config_path}' does not exist" unless File.exists?(config_path)

        config = YAML::load_file(config_path)
        for_stage = config[stage.to_s] || config

        Redis.new(for_stage)
      end
    end
  end
end
