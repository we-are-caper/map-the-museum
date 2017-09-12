# Helper methods defined here can be accessed in any controller or view in the application

MappingMuseum.helpers do
  def revision
    ENV['COMMIT_HASH'] || rand(10000).floor.to_s
  end
end
