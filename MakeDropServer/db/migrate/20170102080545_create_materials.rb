class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.integer :shape_id
      t.integer :geometry_index
      t.timestamps null: false
    end
  end
end
