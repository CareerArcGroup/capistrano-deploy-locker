class Lock
  attr_reader :owner, :expiration, :message

  def initialize(owner, expiration, message)
    @owner = owner
    @expiration = exiration
    @message = message
  end

  def to_s
    [owner, expiration, message].join(";")
  end

  def self.from_s(val)
    owner, exp_str, message = val.split(";")
    Lock.new(owner, exp_str.to_f, message)
  end
end