require 'google/protobuf/well_known_types'

module Internal
  module Ext
    class AddressMessage
        def self.from_string str
            new(Value: [str.sub("0x", "")].pack("H*"))
        end

        def to_s
            "0x"+self.Value.unpack("H*").first
        end

        def inspect
            to_s
        end
    end
  end
end


class Google::Protobuf::Timestamp
    def to_s
        self.to_time.to_s
    end

    def inspect
        self.to_time.inspect
    end
end