require 'levenshtein'

require_relative '../../../lib/circle_distance'
require_relative '../address'

module Responses
  class DetailResponse
    def self.respond(context, listings)
      compare_address = Address.new(context[:address]) if context[:address]

      attributes = listings.values.map do |listing|
        next if listing.nil?
        listing.as_json.tap do |h|
          if listing.respond_to?(:opening_hours)
            h[:opening_hours] = events_for_opening_hours(listing.opening_hours)
          end
          if compare_address
            h[:levenshtein_distance] = Address.new(h).distance(compare_address, Address::ADDRESS_COMPONENTS - [:state])
            h[:distance] = Math.circle_distance(context[:address][:lat], context[:address][:lng], h[:lat], h[:lng])
          end
        end
      end.compact

      if context[:combined]
        (attributes || []).inject({}) do |hash, attrs|
          hash.merge(attrs.delete_if{|k,v| v.nil?})
        end.merge(source: 'Multiple').to_json
      else
        attributes.to_json
      end
    end

    def self.events_for_opening_hours(opening_hours)
      return [] if opening_hours.nil?
      
      #Time.use_zone(timezone) do
        opening_hours['periods'].map do |period|
          start = period['open']
          ending = period['close']
          now = Time.now.beginning_of_week
          day = day_of_week(start['day'])
          {
            starting: now + day.days + hours(start['time']),
            ending: now + day.days + hours(ending['time']),
            recurrence_day: day
          }
        end
      #end
    end

    def self.day_of_week(o)
      return ((o.to_i + 6) % 7)
    end

    def self.hours(o)
      hours = o[0,2].to_i.hours
      minutes = o[2,4].to_i.minutes
      hours + minutes
    end
  end
end
