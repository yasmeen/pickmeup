module Api
  module V1
    class ShapesController < ApplicationController
      skip_before_action :verify_authenticity_token

      def drop

      	result = { status: "failed" }

      	begin
        shape_construction_info = form_shape_from_request(params)
        new_shape = Shape.new(shape_construction_info)
        if new_shape.save
          materials_construction_info = form_materials_from_request(params[:materials], new_shape.id)
          materials_construction_info.each do |material_name, material_data|
            new_material = new_shape.materials.new(material_data)
            if not new_material.save
              return render json: {status: "failed", reason: "Could not store the submitted materials."}
            else
              result = {status: "success", shape_id: "#{new_shape.id}"}
            end
          end
        else
          return render json: {status: "failed", reason: "Could not store the actual shape before affixing materials."}
        end

        rescue Exception => e
          Rails.logger.error "#{e.message}"
        end

        render json: result.to_json

      ensure 
        clean_tempfile
      end


    def form_shape_from_request(top_level_json_data)
      shape = Hash.new
      shape["owner"] = top_level_json_data[:owner]
      shape["type"] = top_level_json_data[:type]
      shape["face_count"] = top_level_json_data[:face_count]
      shape["latitude"] = top_level_json_data[:latitude]
      shape["longitude"] = top_level_json_data[:longitude]
      shape["public"] = top_level_json_data[:public]
      return shape
    end



    def form_materials_from_request(image_level_json_data, shape_id) 
      materials = Hash.new
      image_level_json_data.each do |image_key, image_value|
          material = Hash.new
          #file name of each material is shape_id + "-image" + geometry index
          file_name = "#{shape_id}-#{image_value[:filename]}" 
          decoded_image = parse_image_data(image_value, file_name)
          material["image"] = decoded_image
          material["geometry_index"] = image_value[:geometry_index]
          material["shape_id"] = shape_id
          materials[image_key] = material
      end
      return materials
    end


	  def parse_image_data(image_data, file_name)
	    @tempfile = Tempfile.new('item_image')
	    @tempfile.binmode
	    @tempfile.write Base64.decode64(image_data[:file_data])
	    @tempfile.rewind

	    uploaded_file = ActionDispatch::Http::UploadedFile.new(
	      tempfile: @tempfile,
	      filename: file_name
	    )

	   uploaded_file.content_type = image_data[:content_type]
	   uploaded_file
	  end

	  def clean_tempfile
	    if @tempfile
	      @tempfile.close
	      @tempfile.unlink
	    end
	  end

    end
  end
end