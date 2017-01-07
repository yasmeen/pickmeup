module Api
  module V1
    class DiscoverController < ApplicationController
      skip_before_action :verify_authenticity_token

      SEARCH_RADIUS = .0005
      
      def discover_shape
      	begin
      	params = params.require(:lat, :long)
      	if params.key?(:lat) and params.key?(:long)
	      	#for the protoype, we had a hardcoded search radius 
	      	latitude = params[:lat].to_f
	      	longitude = params[:long].to_f
	      	shapes_in_radius = Shape.where(latitude: (latitude-SEARCH_RADIUS)...(latitude+SEARCH_RADIUS))
	      	shapes_in_radius = shapes_in_radius.where(longitude: (longitude-SEARCH_RADIUS)...(longitude+SEARCH_RADIUS))
	      	return json: {status: "success", data: shapes_in_radius.to_json}

	    else
	    	return render json: {status: "failed", reason: "Longitude and Latitude must be provided"}

	    end 

	    rescue Exception => e
        	Rails.logger.error "#{e.message}"
        end

        return render json: { status: "failed", reason: "An unknown exception has occurred" }
      end
    end
  end
end