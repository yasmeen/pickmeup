class Material < ActiveRecord::Base
	belongs_to :shape
	has_attached_file :image, styles: { 
		small: "64x64", 
		med: "200x200", 
		large: "400x400" 
	}


	validates_attachment :image, content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }
end
