module Responses
  class PhotosResponse
    def self.respond(spot, photos)
      return (photos || []).collect(&:as_json).uniq{|o| o[:key]}.to_json
    end
  end
end
