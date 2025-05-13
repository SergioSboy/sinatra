# frozen_string_literal: true

require 'sequel'

DB = Sequel.connect("sqlite://#{__dir__}/test.db")
