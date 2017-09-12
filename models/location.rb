class Location
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Geospatial

  embedded_in :item

  field :place,  :type => Point, :spatial => true
  field :reason, :type => String
  field :status, :type => String, :default => "undisputed"

  spatial_index :source

 end