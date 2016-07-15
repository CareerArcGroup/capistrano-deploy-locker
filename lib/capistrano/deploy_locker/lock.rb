require "capistrano/deploy_locker/lock"

module Capistrano
  module DeployLocker
    class Lock
      attr_reader :owner, :expiration, :message

      def initialize(owner, expiration, message)
        @owner = owner
        @expiration = expiration
        @message = message
      end

      def to_redis_value
        [owner, expiration.to_f, message].join(";")
      end

      def self.from_redis_value(val)
        owner, exp_str, message = val.split(";")
        Lock.new(owner, Time.at(exp_str.to_f), message)
      end
    end
  end
end