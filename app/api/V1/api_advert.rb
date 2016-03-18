module V1
  class ApiAdvert < Grape::API

    version 'v1', using: :path

    resources 'adverts' do

      # http://localhost:3000/api/v1/adverts
      get "", jbuilder: 'v1/adverts/index' do
        @adverts = Advert.all
        @popular_product = Product.state.hot.sorted
      end
    end
  end
end
