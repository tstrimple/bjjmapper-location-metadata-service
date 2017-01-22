require_relative 'mongo_document'

class GooglePlacesReview
  include MongoDocument
  COLLECTION_NAME = 'google_places_reviews'
  COLLECTION_FIELDS = [:type, :author_name, :author_url, :text, :time, :rating, :_id, :place_id, :bjjmapper_location_id]

  attr_accessor *COLLECTION_FIELDS

  def key
    ['GoogleReview', self.place_id, self.time].join('-')
  end
  
  def as_json
    [:author_name, :author_url, :text, :time, :place_id, :rating, :key].inject({}) do |hash, k|
      hash[k] = self.send(k); hash
    end.merge(source: 'Google') 
  end
end
