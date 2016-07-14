module Capistrano
  module DSL
    module DeployLocker
      def deploy_locker_key
        fetch(:deploy_locker_key, "capistrano:deploy_locker:#{fetch(:application)}")
      end

      def deploy_locker_expiration
        fetch(:deploy_locker_expiration, 60 * 20)
      end
    end
  end
end