MappingMuseum.controllers :items do

  get :home, :map => "/" do
    @ie = (request.env['HTTP_USER_AGENT'] =~ /MSIE/i)
    @ie = true if params[:ie] == "true"
    @android_old = (request.env['HTTP_USER_AGENT'] =~ /Android 2\./i)
    @android = (request.env['HTTP_USER_AGENT'] =~ /Android/i)
    render 'home'
  end

  get :todo, :map => "/items/todo", :provides => [:html, :json] do
    @item = (0..Item.count-1).sort_by{rand}.slice(0, 1).collect! { |i| Item.skip(i).first }.first
    render :"items/todo", :layout => false
  end

  get :proxy_get, :map => "/proxy" do
    Nestful.get params[:url]
  end

  post :proxy_post, :map => "/proxy" do
    Nestful.post params[:url]
  end

  get '/geo', :map => "/geo" do
    content_type :json
    {
      "type" => "FeatureCollection",
      "features" => (Item.where(:status => "located").collect do |item|
        {
          "geometry" =>
          {
            "type" => "Point",
            "coordinates" =>[item.locations.last.place.x, item.locations.last.place.y]
          },
          "properties" => {
            "url" => "/items/#{item.id}",
            "name" => (item.title.nil? ? item.object_name : item.title).chomp("."),
            "thumbnail" => (item.photographs.blank? ? "/images/blank_thumbnail.png" : item.photographs.first.attachment.url(:small))
          }
        }
      end)
    }.to_json
  end

  get :geolocate, :map => "/items/geolocate", :provides => [:json] do
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="
    output = "&sensor=false"
    request = geocoder + params[:address] + ",Brighton,UK" + output
    url = URI.escape(request)
    resp = Net::HTTP.get_response(URI.parse(url))
    result = {}
    if resp.inspect.include?('HTTPOK 200 OK')
      parse = Crack::JSON.parse(resp.body)
      if parse["status"] == "OK"
        result[:lat] = parse["results"].first["geometry"]["location"]["lat"]
        result[:lng] = parse["results"].first["geometry"]["location"]["lng"]
        result[:status] = "success"
      end
    else
      result[:status] = "failure"
    end
    result.to_json
  end

  get :show, :map => "/items/:id" do
    not_found unless @item = Item.find(params[:id])
    render :"items/todo", :layout => false
  end

  put :locate, :map => "/items/:id" do
    content_type :json
    @item = Item.find(params[:id])
    @location = Location.new(:place => [params[:lng], params[:lat]], :status => params[:status], :reason => params[:reason])
    @item.locations << @location
    @item.status = "located"
    @item.located_at = Time.now
    @item.save
    @location.to_json
  end

end
