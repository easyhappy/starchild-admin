class HexSerializer
  # Serializes an attribute value to a string that will be stored in the database.
  def self.dump(value)
    [value.sub("0x", "")].pack("H*")
  end

  # Deserializes a string from the database to an attribute value.
  def self.load(value)
    if value.blank?
        return ""
    end

    "0x"+value.unpack("H*").first
  end
end