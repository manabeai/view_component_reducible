# frozen_string_literal: true

class CreateTimeSlots < ActiveRecord::Migration[8.1]
  def change
    create_table :time_slots do |t|
      t.references :staff, null: false, foreign_key: true
      t.tstzrange :time_range, null: false

      t.timestamps
    end

    add_index :time_slots, :time_range, using: :gist
  end
end
