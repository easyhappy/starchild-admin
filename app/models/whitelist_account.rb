class WhitelistAccount < ApplicationRecord
  serialize :account, HexSerializer
end
