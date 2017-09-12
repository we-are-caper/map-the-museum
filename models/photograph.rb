class Photograph
  include Mongoid::Document
  include Mongoid::Paperclip

  embedded_in :item

  field :title, :type => String

  if Padrino.env == :local
    has_mongoid_attached_file :attachment,
      :path           => Padrino.root+"/public/system/:attachment/:id/:style/:filename.:extension",
      :url           => "/system/:attachment/:id/:style/:filename.:extension",
      :storage        => :filesystem,
      :styles => {
        :original => ['1920x1680>', :jpg],
        :small    => ['100x100#',   :jpg],
        :medium   => ['250x250',    :jpg],
        :large    => ['500x500>',   :jpg]
      },
      :convert_options => { :all => '-background white -flatten +matte' }
  elsif Padrino.env == :development
    has_mongoid_attached_file :attachment,
      :path           => ':attachment/:id/:style.:extension',
      :storage        => :s3,
      :url            => ':s3_alias_url',
      :s3_host_alias  => ENV['S3_HOST_ALIAS'],
      :s3_credentials => File.join(Padrino.root, 'config', 's3.yml'),
      :styles => {
        :original => ['1920x1680>', :jpg],
        :small    => ['100x100#',   :jpg],
        :medium   => ['250x250',    :jpg],
        :large    => ['500x500>',   :jpg]
      },
      :convert_options => { :all => '-background white -flatten +matte' }
  elsif Padrino.env == :production or Padrino.env == :staging
    has_mongoid_attached_file :attachment,
      :path           => ':attachment/:id/:style.:extension',
      :storage        => :s3,
      :url            => ':s3_alias_url',
      :s3_host_alias  => ENV['S3_HOST_ALIAS'],
      :s3_credentials => File.join(Padrino.root, 'config', 's3.yml'),
      :styles => {
        :original => ['1920x1680>', :jpg],
        :small    => ['100x100#',   :jpg],
        :medium   => ['250x250',    :jpg],
        :large    => ['500x500>',   :jpg]
      },
      :convert_options => { :all => '-background white -flatten +matte' }
  end
end
