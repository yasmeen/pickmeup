class AddAttachmentImageToMaterials < ActiveRecord::Migration
  def self.up
    change_table :materials do |t|
      t.attachment :image
    end
  end

  def self.down
    remove_attachment :materials, :image
  end
end
