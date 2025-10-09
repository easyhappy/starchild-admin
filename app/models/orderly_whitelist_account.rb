class OrderlyWhitelistAccount < ApplicationRecord
  serialize :account, HexSerializer
end
