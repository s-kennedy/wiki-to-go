class WikipediaService

  include HTTParty
  attr_accessor :results_array, :results

  def search(params)

    if params.include? :query
      response = search_query(params[:query])
    elsif params.include? :location
      response = search_coords(params[:location])
    else
      "hmmmm what?"
    end
    process_response(response)
    return @results

  end

  def search_query(query)
    # query = params[:query]
    response = HTTParty.get('http://en.wikipedia.org/w/api.php?action=query&format=json&list=geosearch&gslimit=50&gsradius=10000&gspage=' + query )
  end

  def search_coords(location)
		# location = params[:location]
		response = HTTParty.get('http://en.wikipedia.org/w/api.php?action=query&format=json&list=geosearch&gslimit=50&gsradius=10000&gscoord=' + location )
	end

	def process_response(response)

		results = JSON.parse(response.body)

		if response.code != 200
			render 'no_results'
		elsif results["error"].present?
			render 'no_results'
			flash[:search_error] = results["error"]["info"]
		else
			@results_array = results["query"]["geosearch"]
			get_marker_info
			@results_array
		end
	end
 
	def get_marker_info

		@results = []

		@results_array.each do |place|
			title = place["title"]
			lat = place["lat"]
			lon = place["lon"]
			id = place["pageid"]

			@results << {
				title: title, 
				lat: lat,
				lon: lon,
				id: id
			}

		end
	end

end