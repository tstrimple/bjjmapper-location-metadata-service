require_relative 'mongo_document'

class GooglePlacesPhoto
  include MongoDocument
  COLLECTION_NAME = 'google_places_photos'
  COLLECTION_FIELDS = [:width, :height, :photo_reference, :html_attributions, :large_url, :url, :_id, :place_id, :bjjmapper_location_id]

  attr_accessor *COLLECTION_FIELDS
end
