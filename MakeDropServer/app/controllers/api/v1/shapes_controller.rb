module Api
  module V1
    class ShapesController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def drop
      	render :json => {'Hello': 'World'}
      end

    end
  end
end