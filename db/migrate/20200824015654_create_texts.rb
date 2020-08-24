class CreateTexts < ActiveRecord::Migration[6.0]
  def change
    create_table :texts do |t|
      t.integer :audio_id, null: false
      t.integer :time
      t.text :text
    end
  end
end
