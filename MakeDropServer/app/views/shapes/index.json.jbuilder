json.array!(@shapes) do |shape|
  json.extract! shape, :id, :owner, :type, :face_count, :latitude, :longitude, :created_at, :public
  json.url shape_url(shape, format: :json)
end
