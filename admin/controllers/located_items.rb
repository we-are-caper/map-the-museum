Admin.controllers :located_items do

  get :index do
    @items = Item.where(status: "located").order("located_at desc")
    render 'items/index'
  end

end
