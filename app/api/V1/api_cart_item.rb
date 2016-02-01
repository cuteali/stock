module V1
  class ApiCartItem < Grape::API

    helpers do 
      def current_user
        user_token = params[:token]
        AppLog.info("user_token:    #{user_token}")
        @user = User.find_by(token:user_token)
        if @user.present?
          AppLog.info("user_unique_id : #{@user.unique_id}")
          redis_token = @user.phone_num.to_s + @user.unique_id.to_s
          AppLog.info("redis_token:  #{redis_token}")
          @token = $redis.get(redis_token)
          AppLog.info("token is :#{@token}")
        end
        [@token,@user]
      end
    end

    version 'v1', using: :path

    resources 'cart_items' do

      # http://localhost:3000/api/v1/cart_items/:token
      # bcb67d8860d033061090fbbf9f4c605c
      params do 
        requires :token,type: String
      end
      get ":token",jbuilder:"v1/cart_items/index" do
        @token,@user = current_user
        if @token.present?
          @cart_items = @user.cart_items
        end
      end

      #http://localhost:3000/api/v1/cart_items
      params do 
        requires :token,type: String
        requires :pro_unique_id,type:String
      end
      post "",jbuilder:"v1/cart_items/create" do
        @token,@user = current_user
        if @token.present?
          product = Product.find_by(unique_id:params[:pro_unique_id])
          @cart_item = CartItem.create(product_id:product.id,user_id:@user.id,unique_id:SecureRandom.urlsafe_base64)
        end
      end

      #http://localhost:3000/api/v1/cart_items
      params do 
        requires :token,type: String
        requires :pro_unique_ids,type:String
      end
      delete "",jbuilder:"v1/cart_items/delete" do
        @token,@user = current_user
        if @token.present?
          ActiveRecord::BASE.transaction do
            pro_unique_ids = JSON.prase(params[:pro_unique_ids])
            pro_ids = Product.where(id:pro_unique_ids).pluck(:id)
            @cart_items = CartItem.where("user_id = ?",@user.id).where(product_id:pro_ids)
            @cart_items.destroy_all if @cart_items.present?
            @info = "success"
          end
        end
      end
    end
  end
end