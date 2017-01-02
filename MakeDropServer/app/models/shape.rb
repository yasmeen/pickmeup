class Shape < ActiveRecord::Base
	has_many :materials, :dependent => :destroy
end
