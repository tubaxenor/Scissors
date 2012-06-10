require 'net/http'

module Net
  class HTTP
    alias old_initialize initialize
    def initialize(*args)
        old_initialize(*args)
        @read_timeout = 10
    end
  end
end
