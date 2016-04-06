class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :cangaroo_translations do |t|
      t.references :source_connection, index: true
      t.references :destination_connection, index: true

      t.string :job_id

      t.string :object_type
      t.string :object_id
      t.string :object_key

      t.jsonb :request
      t.jsonb :response

      t.timestamps null: false
    end

    add_foreign_key :cangaroo_translations, :cangaroo_connections, column: :source_connection_id
    add_foreign_key :cangaroo_translations, :cangaroo_connections, column: :destination_connection_id
  end
end
