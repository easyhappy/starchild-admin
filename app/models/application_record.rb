class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
  self.inheritance_column = "column_that_is_not_type"
end
