require 'resque'
require 'mongo'
require 'bjjmapper_api_client'
require_relative '../../config'
require_relative '../../database_client'
require_relative '../models/yelp_business'
require_relative '../../lib/circle_distance'
require_relative '../../lib/yelp_fusion_client'

module YelpIdentifyCandidateLocationsJob
  @client = YelpFusionClient.new(ENV['YELP_V3_CLIENT_ID'], ENV['YELP_V3_CLIENT_SECRET'])
  @bjjmapper = BJJMapper::ApiClient.new(LocationFetchService::BJJMAPPER_CLIENT_SETTINGS)

  @queue = LocationFetchService::QUEUE_NAME
  @connection = LocationFetchService::MONGO_CONNECTION

  PAGE_LIMIT = 20
  PAGE_WAIT_SECONDS = 2
  TOTAL_LIMIT = 200
  DEFAULT_TITLE = 'brazilian'
  CATEGORY_FILTER_MARTIAL_ARTS = 'martialarts'
  DEFAULT_DISTANCE_METERS = 40000

  def self.perform(model)
    batch_id = Time.now
    puts "Searching Yelp for listings"
    find_academy_listings(model) do |block|
      block.each do |listing_response|
        listing = YelpBusiness.from_response(listing_response, batch_id: batch_id, primary: true)
        puts "Found business #{listing.name}, #{listing.inspect}"
       
        if should_filter?(listing.name.downcase)
          puts "Filtering #{listing.name} because of title"
          next
        end

        params = { rejected: 1, unverified: 1, closed: 1, sort: 'distance', distance: LocationFetchService::LISTING_DISTANCE_THRESHOLD_MI, lat: listing.lat, lng: listing.lng}
        bjjmapper_nearby_locations = @bjjmapper.map_search(params)
        puts "Founds nearby locations #{bjjmapper_nearby_locations.inspect}"

        listing.bjjmapper_location_id = create_or_associate_nearest_location(listing, bjjmapper_nearby_locations) 
        listing.upsert(@connection, bjjmapper_location_id: listing.bjjmapper_location_id, yelp_id: listing.yelp_id)
      end
    end
  end

  def self.should_filter?(name)
    name_components = name.split.collect(&:downcase).to_set
    filtered_word = LocationFetchService::TITLE_BLACKLIST_WORDS.detect {|word| name_components.include?(word) }
    return !filtered_word.nil?
  end
  
  def self.should_whitelist?(name)
    name_components = name.downcase.split.collect(&:downcase).to_set
    whitelist_word = LocationFetchService::TITLE_WHITELIST_WORDS.detect {|word| name_components.include?(word) }
    return !whitelist_word.nil?
  end

  def self.create_or_associate_nearest_location(listing, nearby_locations)
    nearest = nearby_locations.first
    if !nearest.nil?
      enqueue_associate_listing_job(listing, nearest)
      nearest['id']
    else
      new_loc = create_location_from_listing!(listing)
      enqueue_associate_listing_job(listing, new_loc)
      new_loc['id']
    end
  end

  def self.enqueue_associate_listing_job(listing, location)
    puts "Associating #{listing.yelp_id} with #{location['title']}"
    Resque.enqueue(YelpFetchAndAssociateJob, {
      bjjmapper_location_id: location['id'],
      yelp_id: listing.yelp_id
    })
  end

  def self.create_location_from_listing!(listing)
    puts "Creating candidate location #{listing.name}"
    
    o = listing.as_json
    response = @bjjmapper.create_location({
      title: o[:title],
      coordinates: [o[:lng], o[:lat]],
      street: o[:street], 
      postal_code: o[:postal_code],
      city: o[:city],
      state: o[:state],
      country: o[:country],
      source: 'Yelp',
      phone: o[:phone],
      flag_closed: o[:is_closed],
      status: should_whitelist?(o[:title]) ? BJJMapper::ApiClient::LOCATION_STATUS_VERIFIED : BJJMapper::ApiClient::LOCATION_STATUS_PENDING
    })

    puts "Created #{response['id']} location"
    response
  end

  def self.find_academy_listings(model)
    lat = model['lat']
    lng = model['lng']
    title = model['title'] || DEFAULT_TITLE

    businesses_count = 0
    loop do
      response = @client.search({ radius: DEFAULT_DISTANCE_METERS,
                                  latitude: lat, longitude: lng,
                                  offset: businesses_count, limit: PAGE_LIMIT,
                                  term: title, categories: CATEGORY_FILTER_MARTIAL_ARTS })
      
      puts "Search returned #{(response['businesses'] || []).count} listings"
      break unless response['businesses'] && response['businesses'].count > 0

      yield response['businesses']
      businesses_count = businesses_count + response['businesses'].count

      break if response['businesses'].count < PAGE_LIMIT || businesses_count >= TOTAL_LIMIT
    
      sleep(PAGE_WAIT_SECONDS)
    end
  end
end
