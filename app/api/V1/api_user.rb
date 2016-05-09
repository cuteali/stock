module V1
  class ApiUser < Grape::API

    version 'v1', using: :path

    resources 'users' do

      # http://localhost:3000/api/v1/users/user_info
      params do
        requires :token, type: String
      end
      post "user_info", jbuilder: 'v1/users/show' do
        # phone_num_encrypt = params[:phone_num]
        # @user = User.find_by(phone_num:phone_num_encrypt)
      end

      # http://localhost:3000/api/v1/users/send_sms
      params do
        requires :phone_num, type: String
      end
      post 'send_sms',jbuilder:"v1/users/send_sms" do
        phone_num_encrypts = [params[:phone_num]]
        rand = Sms.rand_code
        text = "【要货啦】您的验证码是#{rand}。如非本人操作，请忽略本短信！"
        @info = Sms.send_sms(phone_num_encrypts, text, rand)
        AppLog.info("info:#{@info}")
      end

      #http://localhost:3000/api/v1/users/sign_in
      params do
        requires :phone_num, type: String
        requires :rand_code, type: String
      end
      post "sign_in",jbuilder:"v1/users/sign_in" do
        phone_num_encrypt = params[:phone_num]
        rand_code = params[:rand_code]
        @token,unique_id = User.sign_in(phone_num_encrypt,rand_code)
        if @token.present?
          redis_token = phone_num_encrypt + unique_id
          $redis.set(redis_token,@token)
          $redis.expire(redis_token,24*3600*15)
          # cookies[phone_num_encrypt] = {value:@token,expires:10.day.from_now}
        end
      end

      #http://localhost:3000/api/v1/users/token
      params do
        requires :token, type: String
      end
      post 'token',jbuilder:"v1/users/token" do
        if @token.present?
          @token = SecureRandom.urlsafe_base64
          redis_token = @user.phone_num + @user.unique_id
          $redis.set(redis_token,@token)
          $redis.expire(redis_token,24*3600*15)
          @user.update(token:@token)
        else
          @token = nil
        end
      end

      #http://localhost:3000/api/v1/users
      params do
        requires :token, type: String
        #requires :new_phone_num,type:String
        requires :user_name, type: String
        #requires :head_portrait,type:String
      end
      put '',jbuilder:"v1/users/update" do 
        if @token.present?
          ActiveRecord::Base.transaction do
            @user.phone_num = params[:new_phone_num] if params[:new_phone_num].present?
            @user.user_name = params[:user_name] if params[:user_name].present?
            @user.save
            #@user.update(phone_num:params[:new_phone_num],user_name:params[:user_name])
            if params[:head_portrait].present?
              @user.images.destroy_all
              @image_util = ImageUtil.base64_image(params[:head_portrait],"User",@user.id)
            end
            @flag = "1"
          end
        end
      end
    end
  end
end
