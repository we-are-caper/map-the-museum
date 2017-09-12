Admin.controllers :disputed_items do

  get :index do
    @items = Item.where('locations.status' => "disputed")
    render 'items/disputed_index'
  end

  put :confirm, :with => :id do 
  	@item = Item.find(params[:id])
  	@item.locations.last.status = "confirmed"
    if @item.update_attributes(params[:item])
      flash[:notice] = 'Location was successfully confirmed.'
      redirect url(:disputed, :items, :index)
    else
      flash[:error] = 'Location was not confirmed.'
      redirect url(:disputed, :items, :index)
    end
  end

end
