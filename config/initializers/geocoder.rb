geocoder_options = {
  timeout: 5,
  units: :km,
  distances: :linear
}

if ENV["MAPBOX_API_KEY"].present?
  geocoder_options.merge!(
    lookup: :mapbox,
    api_key: ENV["MAPBOX_API_KEY"]
  )
else
  geocoder_options.merge!(
    lookup: :nominatim,
    http_headers: { "User-Agent" => "RES-Project" }
  )
end

Geocoder.configure(geocoder_options)
