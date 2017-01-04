module Api
  module V1
    class ShapesController < ApplicationController
      
      def drop
      	render :json => {'Hello': 'World'}
      end

    end
  end
end