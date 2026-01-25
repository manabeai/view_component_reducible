# frozen_string_literal: true

class Staff < ApplicationRecord
  has_many :time_slots, dependent: :destroy

  validates :name, presence: true
end
