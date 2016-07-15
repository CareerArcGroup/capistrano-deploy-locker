module Capistrano
  module DSL
    module DeployLocker
      def deploy_locker_redis_config_file
        fetch(:deploy_locker_redis_config_file)
      end

      def deploy_locker_key_prefix
        fetch(:deploy_locker_key_prefix)
      end

      def deploy_locker_expiration
        fetch(:deploy_locker_expiration)
      end
    end
  end
end