class CreateCangarooAttempts < ActiveRecord::Migration
  def change
    create_table :cangaroo_attempts do |t|
      t.references :translation, index: true
      t.integer :response_code
      t.jsonb :response

      t.timestamps null: false
    end

    add_foreign_key :cangaroo_attempts, :cangaroo_translations, column: :translation_id
  end
end
