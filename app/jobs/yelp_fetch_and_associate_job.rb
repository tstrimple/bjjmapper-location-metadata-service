require 'resque'
require 'mongo'
require_relative '../../config'
require_relative '../models/yelp_business'
require_relative '../models/yelp_review'
require_relative '../../lib/yelp_fusion_client'

module YelpFetchAndAssociateJob
  @client = YelpFusionClient.new(ENV['YELP_V3_CLIENT_ID'], ENV['YELP_V3_CLIENT_SECRET'])
  @queue = LocationFetchService::QUEUE_NAME
  @connection = Mongo::MongoClient.new(LocationFetchService::DATABASE_HOST, LocationFetchService::DATABASE_PORT).db(LocationFetchService::DATABASE_APP_DB)

  def self.perform(model)
    bjjmapper_location_id = model['bjjmapper_location_id']
    listing = @client.business(URI::encode(model['yelp_id']))
    detailed_listing = build_listing(listing, bjjmapper_location_id)
    
    reviews_response = @client.reviews(URI::encode(listing['id']))
    puts "reviews response is #{reviews_response.inspect}"
    reviews_response['reviews'].each do |review_response|
      review = build_review(review_response, bjjmapper_location_id, listing['id'])
      puts "Storing review #{review.inspect}"
      review.upsert(@connection, yelp_id: detailed_listing.yelp_id, time_created: review.time_created, user_name: review.user_name)
    end if reviews_response && reviews_response['reviews']
    
    puts "Storing listing #{detailed_listing.inspect}"
    detailed_listing.save(@connection)
  end

  def self.build_listing(listing_response, location_id)
    return YelpBusiness.new(listing_response).tap do |r|
      r.name = listing_response['name']
      r.yelp_id = listing_response['id']
      r.merge_attributes!(listing_response['location'])
      if listing_response['coordinates']
        r.lat = listing_response['coordinates']['latitude']
        r.lng = listing_response['coordinates']['longitude']
      end
      r.bjjmapper_location_id = location_id
      r.primary = true
    end
  end
  
  def self.build_review(review_response, location_id, yelp_id)
    return YelpReview.new(review_response).tap do |r|
      r.bjjmapper_location_id = location_id
      r.user_id = review_response['user']['id']
      r.user_image_url = review_response['user']['image_url']
      r.user_name = review_response['user']['name']
      r.yelp_id = yelp_id
    end
  end
end
