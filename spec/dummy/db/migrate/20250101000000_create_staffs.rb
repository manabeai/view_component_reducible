# frozen_string_literal: true

class CreateStaffs < ActiveRecord::Migration[8.1]
  def change
    create_table :staffs do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
