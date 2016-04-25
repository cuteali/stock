module V1
  class ApiFavorite < Grape::API

    version 'v1', using: :path

    resources 'favorites' do
      # http://localhost:3000/api/v1/favorites
      params do
        requires :token, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/favorites/index' do
        if @token.present?
          @favorites = @user.favorites.latest.by_page(params[:page_num])
        end
      end

      # http://localhost:3000/api/v1/favorites
      params do
        requires :token, type: String
        requires :unique_id, type: String
      end
      post '', jbuilder: 'v1/favorites/create' do
        if @token.present?
          product = Product.find_by(unique_id:params[:unique_id])
          @favorite = @user.favorites.create(product_id: product.try(:id), unique_id: SecureRandom.urlsafe_base64)
        end
      end

      #http://localhost:3000/api/v1/favorites
      params do 
        requires :token, type: String
        requires :unique_id, type: String
      end
      delete '', jbuilder: 'v1/favorites/delete' do
        if @token.present?
          favorite = @user.favorites.find_by(unique_id: params[:unique_id])
          if favorite.present?
            @favorite = favorite.destroy
          end
        end
      end

      #http://localhost:3000/api/v1/favorites/delete_all
      params do 
        requires :token, type: String
      end
      get 'delete_all', jbuilder: 'v1/favorites/delete_all' do
        if @token.present?
          favorites = @user.favorites
          if favorites.present?
            @favorites = favorite.destroy_all
          end
        end
      end
    end
  end
end
