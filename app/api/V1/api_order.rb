module V1
  class ApiOrder < Grape::API

    version 'v1', using: :path

    helpers do
      def send_to_shop(order)
        phone_num_encrypts = ['C3A06D455704B6ACA7253EEBE3C2E6D0', '42D496FBA94A4900AFE5105D4D4D7E03', 'B31193480E86B34F22A7DAE61A6AA1A0']
        text = "【要货啦】您好，您有来自 #{@order.receive_name} 的要货单！请查看处理～"
        info = Sms.send_sms(phone_num_encrypts, text)
        AppLog.info("info:#{info}")
      end

      def send_to_user(user, order)
        reg = /^1[3|4|5|8][0-9]\d{8}$/
        phone_num_encrypts = []
        phone_num_encrypts << AesUtil.aes_encrypt($key, user.phone) if user.phone =~ reg
        phone_num_encrypts << AesUtil.aes_encrypt($key, order.phone_num) if order.phone_num =~ reg
        if phone_num_encrypts.present?
          text = "【要货啦】您好，已经收到您的订单，正在为您准备货物，请保持手机畅通，如有疑问，请拨打客服电话 400-0050-383。"
          info = Sms.send_sms(phone_num_encrypts.uniq, text)
          AppLog.info("info:#{info}")
        end
      end
    end

    resources 'orders' do
      # http://localhost:3000/api/v1/orders
      # bcb67d8860d033061090fbbf9f4c605c
      params do 
        requires :token,type: String
        requires :state,type: String
      end
      get "",jbuilder:"v1/orders/index" do
        if @token.present?
          state_json = JSON.parse(params[:state].gsub("\\",""))
          @orders = Order.where(user_id: @user.id, state: state_json).latest
        end
      end

      #http://localhost:3000/api/v1/orders
      params do 
        requires :token, type: String
        requires :receive_name, type: String
        requires :phone_num, type: String
        requires :address_id, type: String
        requires :products, type: String
        requires :money, type: String
        optional :remarks, type: String
      end
      post "",jbuilder:"v1/orders/create" do
        if @token.present? && @user.is_verified?
          AppLog.info("products : #{params[:products]}")
          address = Address.find_by(unique_id:params[:address_id])
          products_json = params[:products].gsub("\\","")
          AppLog.info("products_json : #{products_json}")
          ActiveRecord::Base.transaction do 
            product_arr = JSON.parse(products_json)
            order_money, @is_restricting, @is_send_out = Order.check_order_money(@user, product_arr)
            AppLog.info("money:#{params[:money]}")
            if !@is_restricting && !@is_send_out
              @delivery_price = SystemSetting.first.try(:delivery_price)
              @is_sending_price = order_money >= @delivery_price.to_f
              if (order_money == params[:money].gsub(/[^\d\.]/, '').to_f) && @is_sending_price
                @stock_num_result, @is_sold_off = Product.validate_stock_num(product_arr)
                if @stock_num_result == 0 && !@is_sold_off
                  @order = Order.create(state: 0, phone_num: params[:phone_num], receive_name: params[:receive_name], user_id: @user.id, area: address.try(:area), detail: address.try(:detail), order_money: order_money, unique_id: SecureRandom.urlsafe_base64, remarks: params[:remarks])
                  @order.create_orders_products(@user, product_arr)
                  pro_ids = @order.update_product_stock_num
                  AppLog.info("pro_ids:      #{pro_ids}")
                  @cart_items = CartItem.where(user_id: @user.id, product_id: pro_ids)
                  AppLog.info("cart_items:   #{@cart_items.pluck(:id)}")
                  @cart_items.destroy_all if @cart_items.present?
                  if @order
                    send_to_shop(@order)
                    send_to_user(@user, @order)
                  end
                end
              end
            end
          end
        end
      end

      #http://localhost:3000/api/v1/orders/:unique_id
      params do 
        requires :token,type:String
        requires :unique_id,type:String
      end
      get ":unique_id",jbuilder:"v1/orders/show" do
        if @token.present?
          @order = Order.find_by(unique_id:params[:unique_id])
          @products = @order.orders_products.joins(:product).order('products.category_id ASC')
        end
      end
    end
  end
end
