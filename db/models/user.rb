# frozen_string_literal: true

class User < Sequel::Model
  many_to_one :template
  one_to_many :operations
end
