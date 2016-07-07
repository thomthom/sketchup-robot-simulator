module TT::Plugins::Bot

  class BaseObject

    def typename
      self.class.name.split('::').last
    end

    def inspect
      "<#{self.class}:#{object_id_hex} #{object_info}>"
    end

    def to_s
      "#{typename} #{object_info}"
    end

    def object_id_hex
      "0x%x" % ( object_id << 1 )
    end

    def object_info
      ''
    end

  end # class

end # module
