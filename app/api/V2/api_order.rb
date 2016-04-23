module V2
  class ApiOrder < Grape::API

    version 'v2', using: :path

    resources 'orders' do
      #http://localhost:3000/api/v2/orders/:unique_id
      params do 
        requires :token,type:String
        requires :unique_id,type:String
      end
      get ":unique_id",jbuilder:"v2/orders/show" do
        if @token.present?
          @order = Order.find_by(unique_id:params[:unique_id])
          @products = @order.orders_products.joins(:product).group_by{ |op| op.product.category.name }
        end
      end
    end
  end
end
