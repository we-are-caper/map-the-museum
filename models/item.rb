class Item
  include Mongoid::Document
  include Mongoid::Timestamps # adds created_at and updated_at fields

  embeds_many :photographs
  embeds_many :locations

  field :identification_code, :type => String
  field :image_reference, :type => String
  field :museum_collection, :type => String
  field :object_name, :type => String
  field :title, :type => String
  field :description, :type => String
  field :creator, :type => String
  field :date_created, :type=> String
  field :materials, :type => String
  field :place_collected, :type => String
  field :status, :type => String, :default => "unlocated"
  field :source, :type => String
  field :located_at, :type=> DateTime

  def self.from_csv path
    FasterCSV.foreach( 
      path, 
      :headers           => true,
      :header_converters => :symbol,
      :converters        => :numeric 
    ) do |line|

      if Item.first(:conditions => {:identification_code => line[:id]})
        Item.create( {
          :identification_code => line[:id],
          :image_reference => line[:image_ref],
          :museum_collection => line[:collection],
          :description => line[:description],
          :materials => line[:materials],
          :title => line[:title],
          :object_name => line[:object_name],
          :creator => line[:creator],
          :source => line[:source],
          :creator => line[:creator],
          :place_collected => line[:place_collected]
          }
        )
      end
    end
  end

  def self.associate_photos path

    # File.chmod(0777, path)
    # Dir.foreach(path) do |filename|
    #   unless File.directory?(filename)
    #     item = Item.where({:image_reference => filename}).first
    #     puts item.inspect
    #     if item
    #       #if item.photographs.blank?
    #         photo = Photograph.new(:title => filename)
    #         photo.attachment = File.new(path + "/" + filename)
    #         #photo.save
    #         #if photo.valid?
    #           item.photographs << photo
    #           item.save
    #         #end
    #       #end
    Dir.foreach(path) do |filename|
      unless File.directory?(filename)
        item = Item.first(:conditions => {:image_reference => filename})
        if item
          if item.photographs.blank?
            photo = Photograph.new(:title => filename)
            photo.attachment = File.new(path + "/" + filename)
            if photo.valid?
              item.photographs << photo
              item.save
            end
          end
        else
          puts "Missing #{path}" 
        end
      end
    end
  end
end
