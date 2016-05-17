module V1
  class ApiAdvert < Grape::API

    version 'v1', using: :path

    resources 'adverts' do

      # http://localhost:3000/api/v1/adverts
      get "", jbuilder: 'v1/adverts/index' do
        @adverts = Advert.all
        @popular_product = Product.state.hot.sorted
      end

      # http://localhost:3000/api/v1/adverts/advert
      get "advert", jbuilder: 'v1/adverts/advert' do
        @adverts = Advert.all
        @categories = Category.sorted.take(8)
      end

      # http://localhost:3000/api/v1/adverts/hot_products
      params do
        optional :token, type: String
        optional :page_num, type: String
      end
      get "hot_products", jbuilder: 'v1/adverts/hot_products' do
        @popular_product = Product.state.hot.sorted.by_page(params[:page_num])
      end
    end
  end
end
