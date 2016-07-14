module Capistrano
  module DeployLocker
    module Helpers

      def deploy_user
        @deploy_user ||= capture(:id, "-un")
      end

    end
  end
end
