module Version
  @VERSION = "0.3.0"
  class << self
    attr_reader :VERSION
  end
end
