# frozen_string_literal: true

# Bass model class that all other models inherit from
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
