require 'csv'

Admin.controllers :base do

	get :index, :map => "/" do
		render "base/index"
	end

  get :image_select do
    render "base/image_select"
  end

  post :image_upload do
    filename = params[:name]
    puts filename
    item = Item.first(:conditions => {:image_reference => filename})
    puts item
    puts params[:file][:tempfile]
    if item
      if item.photographs.blank?
        photo = Photograph.new(:title => filename)
        photo.attachment = params[:file][:tempfile]
        puts photo.inspect
        if photo.valid?
          puts photo.attachment
          item.photographs << photo
          item.save
        end
      end
    end
  end

	post :upload do
    unless params[:file] &&
           (tmpfile = params[:file][:tempfile]) &&
           (name = params[:file][:filename])
      @error = "No file selected"
      flash[:error] = "No file selected."
      redirect url(:items, :index)
    end
    STDERR.puts "Uploading file, original name #{name.inspect}"
    # while blk = tmpfile.read(65536)
    #   # here you would write it to its final location
    #   STDERR.puts blk.inspect
    # end
    CSV.foreach(
      tmpfile.path,
      :headers           => true,
      :header_converters => :symbol,
      :converters        => :numeric
    ) do |line|
      STDERR.puts "#{Item.first(:conditions => {:identification_code => line[:id]})}"
      unless Item.first(:conditions => {:identification_code => line[:id]})
        Item.create( {
          :identification_code => line[:id],
          :image_reference => line[:image_ref],
          :museum_collection => line[:collection],
          :description => line[:description],
          :materials => line[:materials],
          :title => line[:title],
          :date_created => line[:date_created],
          :object_name => line[:object_name],
          :creator => line[:creator],
          :source => line[:source],
          :place_collected => line[:place_collected],
          :located_at => line[:located_at],
          }
        )
      end
    end
    flash[:notice] = "File was successfully uploaded."
    redirect url(:items, :index)
  end

  get :download do
    filename = "items_"+Time.now.strftime("%Y-%m-%d_%H-%M")
    path = Padrino.root+"/tmp/"+filename
    file = CSV.open(path, "w") do |csv|
      csv << ["ID", "Image ref", "Collection", "Description", "Materials", "Title", "Object name", "Creator", "Place collected", "Date created", "Source", "Created at", "Updated at", "Located at", "Status"]
      Item.all.each do |item|
        STDERR.puts "#{csv}"
        csv << [item.identification_code, item.image_reference, item.museum_collection, item.description, item.materials, item.title, item.object_name, item.creator, item.place_collected, item.date_created, item.source, item.created_at.strftime("%l:%M%p, %e %B %Y, %z"), item.updated_at.strftime("%l:%M%p, %e %B %Y, %z"), item.located_at ? item.located_at.strftime("%l:%M%p, %e %B %Y, %z") : item.located_at, item.status]
      end
    end

    send_file(path, :filename => "#{filename}.csv", :type => "text/plain", :header => "present")
  end

end
