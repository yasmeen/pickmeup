class CreateShapes < ActiveRecord::Migration
  def change
    create_table :shapes do |t|
      t.string :owner
      t.string :name
      t.integer :face_count
      t.float :latitude
      t.float :longitude
      t.boolean :public
      t.timestamps null: false
    end
  end
end
