#
# Behavior for disabling JSObfu during spec runs
#
module JSObfu::Disable

  module ClassMethods
    # Set up some class variables for allowing specs
    @@lock = Mutex.new
    @@disabled = false

    # Disables obfuscation globally, useful for unit tests etc
    def disabled=(val)
      @@lock.synchronize { @@disabled = val }
    end

    # Disables obfuscation globally, useful for unit tests etc
    def disabled?
      @@disabled
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

end
