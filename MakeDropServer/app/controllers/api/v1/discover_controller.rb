module Api
  module V1
    class DiscoverController < ApplicationController
      skip_before_action :verify_authenticity_token

      SEARCH_RADIUS = 0.05
      MAX_NUMBER_OF_SHAPES_DISCOVERED_AT_ONCE = 5

      #we need to filter shapes that the user already discovered
      #we also need to throttle the number of shapes that can appear at one given time
      def discover_shapes
      	begin
      	location = params.permit(:lat, :long)
      
      	if location.key?(:lat) and params.key?(:long)
	      	#for the protoype, we have a hardcoded search radius 
	      	latitude = location[:lat].to_f
	      	longitude = location[:long].to_f
	      	shapes_in_radius = Shape.where(latitude: (latitude-SEARCH_RADIUS)...(latitude+SEARCH_RADIUS))
	      	shapes_in_radius = shapes_in_radius.where(longitude: (longitude-SEARCH_RADIUS)...(longitude+SEARCH_RADIUS))
	      	shapes_in_radius_json = include_materials_and_jsonify(shapes_in_radius)
	      	return render json: {status: "success", data: shapes_in_radius_json}

	    else
	    	return render json: {status: "failed", reason: "Longitude and Latitude must be provided"}

	    end 

	    rescue Exception => e
        	Rails.logger.error "#{e.message}"
        end

        return render json: { status: "failed", reason: "An unknown exception has occurred" }

      end

      def include_materials_and_jsonify(shapes_in_radius)
      	shape_json = Hash.new
      	shapes_in_radius.each do |shape|
	      	shape_json[shape.id] = Hash.new
	      	shape_json[shape.id]["shape"] = shape
	      	shape_json[shape.id]["materials"] = Hash.new
      		shape.materials.each do |material|
      			shape_json[shape.id]["materials"][material.geometry_index] = read_image(material)
      		end
      	end


      	return shape_json.to_json
      end

      def read_image(material)
      	Base64.encode64(open(material.image.url(:original)) {|io| io.read})
      end

    end
  end
end