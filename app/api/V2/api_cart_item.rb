module V2
  class ApiCartItem < Grape::API

    version 'v2', using: :path

    resources 'cart_items' do

      # http://localhost:3000/api/v2/cart_items/:token
      # bcb67d8860d033061090fbbf9f4c605c
      params do 
        requires :token,type: String
      end
      get ":token",jbuilder:"v2/cart_items/index" do
        if @token.present?
          @cart_items = @user.cart_items.joins(:product).group_by{ |cart_item| cart_item.product.category.try(:name) }
          @cart_item_total_num = CartItem.total_product_num(@user)
          @delivery_price = SystemSetting.first.try(:delivery_price)
        end
      end
    end
  end
end