class Material < ActiveRecord::Base
	belongs_to :shape
	has_attached_file :image
	validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }
end
