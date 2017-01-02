class MaterialsController < ApplicationController
 
	def index
		@materials = Material.all
	end
 
 	def new
 		@material = Material.new
 	end
 
 	def create
 		@material = Material.new(post_params)
 		if @material.save
 			redirect_to materials_path
 		else
 			render :new
 		end
 	end
 
 	private
 
 	def post_params
 		params.require(:material).permit(:geometry_index, :shape_id, :created_at, :image)
 	end

end