# frozen_string_literal: true

class Template < Sequel::Model
  one_to_many :users
end
