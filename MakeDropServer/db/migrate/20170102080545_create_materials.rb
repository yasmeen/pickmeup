class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.integer :shape_id
      #t.attachment :image
      t.integer :geometry_index
      t.datetime :created_at

      t.timestamps null: false
    end
  end
end
