require 'resque'
require 'mongo'
require_relative '../../config'
require_relative '../../database_client'
require_relative '../models/yelp_business'
require_relative '../../lib/yelp_fusion_client'
require_relative './google_fetch_and_associate_job'

module YelpSearchJob
  @client = YelpFusionClient.new(ENV['YELP_V3_CLIENT_ID'], ENV['YELP_V3_CLIENT_SECRET'])
  @queue = LocationFetchService::QUEUE_NAME
  @connection = LocationFetchService::MONGO_CONNECTION

  def self.perform(model)
    bjjmapper_location_id = model['id']
    batch_id = Time.now

    listings = find_best_listings(model)
    if listings.nil? || listings.count == 0
      puts "Couldn't find anything"
      return
    end

    listings.first.tap do |listing|
      puts "First listing is #{listing.inspect}"
      Resque.enqueue(YelpFetchAndAssociateJob, {
        bjjmapper_location_id: bjjmapper_location_id,
        yelp_id: listing['id']
      })
    end

    listings.drop(1).each do |listing|
      puts "Storing secondary listing #{listing['id']}"
      build_listing(listing, bjjmapper_location_id, batch_id).tap do |o|
        o.primary = false
        o.upsert(@connection, yelp_id: o.yelp_id)
      end
    end
  end

  def self.find_best_listings(model)
    lat = model['lat']
    lng = model['lng']
    title = model['title']

    response = @client.search({ latitude: lat, longitude: lng, term: title, categories: 'martialarts' })
    listings = response['businesses']
    puts "Search returned #{listings.count} listings"

    if listings.nil?
      response = @client.search({ latitude: lat, longitude: lng, categories: 'martialarts' })
      listings = response['businesses']
      puts "Search returned #{listings.count} listings (using categories: martialarts)"
    end

    if !listings.nil?
      listings = listings.sort_by do |listing|
        distance = Math.circle_distance(lat, lng, listing['coordinates']['latitude'], listing['coordinates']['longitude'])
        puts "Listing '#{listing['name']}' is #{distance} away from the location"
        distance
      end.select do |listing|
        distance = Math.circle_distance(lat, lng, listing['coordinates']['latitude'], listing['coordinates']['longitude'])
        distance < LocationFetchService::LISTING_DISTANCE_THRESHOLD_MI
      end
    end

    listings
  end

  def self.build_listing(listing_response, location_id, batch_id)
    return YelpBusiness.from_response(listing_response, bjjmapper_location_id: location_id, batch_id: batch_id)
  end
end
