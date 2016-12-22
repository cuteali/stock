module V2
  class ApiOrder < Grape::API

    version 'v2', using: :path

    resources 'orders' do
      # http://localhost:3000/api/v2/orders
      # bcb67d8860d033061090fbbf9f4c605c
      params do
        requires :token,type: String
        requires :state,type: String
        optional :page_num, type: String
      end
      #state: 0 全部 1 已生效 2 送货中 3 已完成 4 已取消
      get "",jbuilder:"v2/orders/index" do
        if @token.present?
          @orders = @user.orders.by_new_state(params[:state]).latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v2/orders/cancel
      params do
        requires :token,type:String
        requires :unique_id,type:String
      end
      get "cancel",jbuilder:"v2/orders/cancel" do
        if @token.present?
          order = Order.find_by(unique_id:params[:unique_id])
          if order
            order.restore_products
            @order = order.update(state: 3)
          end
        end
      end

      #http://localhost:3000/api/v2/orders/:unique_id
      params do
        requires :token,type:String
        requires :unique_id,type:String
        optional :message_id, type: String
      end
      get ":unique_id",jbuilder:"v2/orders/show" do
        if @token.present?
          @order = Order.find_by(unique_id:params[:unique_id])
          @products = @order.orders_products.joins(:product).order('products.category_id ASC')
          if params[:message_id]
            message = Message.normal.find_by(id: params[:message_id])
            message.read! if message.present?
          end
        end
      end
    end
  end
end
