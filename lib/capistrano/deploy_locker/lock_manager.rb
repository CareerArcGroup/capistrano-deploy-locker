class LockManager
  class << self
    def configure(options={})
      options.merge!(options)
    end

    def locked?
      lock = get_lock_value
      !lock.nil? && (lock.expiration >= Time.now.to_f)
      locked ? lock : false
    end

    def lock(owner, expiration, message)
      lock = nil
      acquired = redis.setnx(key, build_lock_value(owner, message))

      return true if acquired

      if (lock = get_lock_value && lock.expiration < Time.now.to_f
        if (lock = get_lock_value(redis.getset(key, build_lock_value(owner, message))) && lock.expiration < Time.now.to_f)
          return true
        end
      end

      return false
    end

    def clear
      redis.del(key)
    end

    private

    def options
      @options ||= {}
    end

    def key
      options.fetch(:key, "capistrano:deploy_locker")
    end

    def redis
      options.fetch(:redis, Redis.current)
    end

    def expiration
      options.fetch(:expiration, 20 * 60)
    end

    def generate_expiration
      (Time.now + expiration.to_f + 1).to_f
    end

    def build_lock_value(owner, message)
      Lock.new(owner, generate_expiration, message).to_s
    end

    def get_lock_owner(val)
      lock = get_lock_value(val)
      lock.nil? ? nil : lock.owner
    end

    def get_lock_expiration(val)
      lock = get_lock_value(val)
      lock.nil? ? 0.0 : lock.expiration
    end

    def get_lock_value(val=nil)
      val ||= redis.get(key)
      val.nil? ? nil : Lock.from_s(val)
    end
  end
end