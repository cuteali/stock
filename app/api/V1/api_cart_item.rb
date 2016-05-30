module V1
  class ApiCartItem < Grape::API

    version 'v1', using: :path

    resources 'cart_items' do

      # http://localhost:3000/api/v1/cart_items/:token
      # bcb67d8860d033061090fbbf9f4c605c
      params do 
        requires :token,type: String
      end
      get ":token",jbuilder:"v1/cart_items/index" do
        if @token.present?
          @cart_items = @user.cart_items
        end
      end

      #http://localhost:3000/api/v1/cart_items
      params do 
        requires :token,type: String
        requires :pro_unique_id,type: String
        requires :product_num, type: String
      end
      post "",jbuilder:"v1/cart_items/create" do
        if @token.present?
          @product = Product.find_by(unique_id:params[:pro_unique_id])
          @cart_item = CartItem.find_by(product_id: @product.id, user_id: @user.id)
          @is_restricting = CartItem.create_items_restricting(@cart_item, @user, @product, params[:product_num])
          if !@is_restricting
            if @cart_item
              @cart_item.product_num += params[:product_num].to_i
              @cart_item.save
            else
              @cart_item = CartItem.create(product_id: @product.id, user_id: @user.id, product_num: params[:product_num], unique_id: SecureRandom.urlsafe_base64)
            end
            @cart_item_total_num = CartItem.total_product_num(@user)
            @info = "success"
          end
        end
      end

      #http://localhost:3000/api/v1/cart_items/edit_product_num
      params do 
        requires :token, type: String
        requires :unique_id, type: String
        requires :product_num, type: String
      end
      post "edit_product_num", jbuilder: "v1/cart_items/edit_product_num" do
        if @token.present?
          @cart_item = CartItem.find_by(user_id: @user.id, unique_id: params[:unique_id])
          if @cart_item
            @is_restricting = CartItem.edit_items_restricting(@user, @cart_item.product, params[:product_num])
            if !@is_restricting
              @cart_item.product_num = params[:product_num]
              @result = @cart_item.save
              @cart_item_total_num = CartItem.total_product_num(@user)
            end
          end
        end
      end

      #http://localhost:3000/api/v1/cart_items/order_batch_entry
      params do 
        requires :token, type: String
        requires :unique_id, type: String
      end
      post "order_batch_entry", jbuilder: "v1/cart_items/order_batch_entry" do
        if @token.present?
          @order = Order.find_by(unique_id:params[:unique_id])
          @stock_num_result = @order.validate_product_stock_num
          if @stock_num_result == 0
            @restricting_pro_num = 0
            @order.orders_products.each do |op|
              @cart_item = CartItem.find_by(product_id: op.product_id, user_id: @order.user_id)
              @is_restricting = CartItem.again_items_restricting(@cart_item, @user, op)
              if @is_restricting
                @restricting_pro_num += 1
              else
                if @cart_item.present?
                  @cart_item.product_num += op.product_num
                  @cart_item.save
                else
                  @cart_item = CartItem.create(product_id: op.product_id, user_id: @order.user_id, product_num: op.product_num, unique_id: SecureRandom.urlsafe_base64)
                end
              end
              @info = "success"
            end
          end
        end
      end

      #http://localhost:3000/api/v1/cart_items
      params do 
        requires :token,type: String
        requires :unique_ids,type:String
      end
      delete "",jbuilder:"v1/cart_items/delete" do
        AppLog.info("unique_ids: #{params[:unique_ids]}")
        unique_ids_json = JSON.parse(params[:unique_ids].gsub("\\",""))
        AppLog.info("unique_ids_json:  #{unique_ids_json}")
        if @token.present?
          ActiveRecord::Base.transaction do
            @cart_items = CartItem.where(user_id: @user.id, unique_id: unique_ids_json)
            AppLog.info("ids:   #{@cart_items.pluck(:id)}") if @cart_items.present?
            @cart_items.destroy_all if @cart_items.present?
            @cart_item_total_num = CartItem.total_product_num(@user)
            @info = "success"
          end
        end
      end
    end
  end
end