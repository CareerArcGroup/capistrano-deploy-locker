class LockManager
  class << self
    def configure(options={})
      @options ||= {}
      @options.merge!(options)
    end

    def locked?
      lock = get_lock_value
      locked = !lock.nil? && (lock.expiration.to_f >= Time.now.to_f)
      locked ? lock : false
    end

    def lock(owner, message)
      lock = nil
      acquired = redis.setnx(key, build_lock_value(owner, message))

      return true if acquired

      if (lock = get_lock_value) && lock.expiration.to_f < Time.now.to_f
        if (lock = get_lock_value(redis.getset(key, build_lock_value(owner, message)))) && lock.expiration.to_f < Time.now.to_f
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
      Lock.new(owner, generate_expiration, message).to_redis_value
    end

    def get_lock_value(val=nil)
      val ||= redis.get(key)
      val.nil? ? nil : Lock.from_redis_value(val)
    end
  end
end