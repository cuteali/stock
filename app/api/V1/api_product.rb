module V1
  class ApiProduct < Grape::API

    version 'v1', using: :path

    resources 'products' do

      # http://localhost:3000/api/v1/products/:unique_id
      params do
        requires :unique_id, type: String
      end
      get ":unique_id", jbuilder: 'v1/products/show' do
        @product = Product.find_by(unique_id:params[:unique_id])
      end

      #http://localhost:3000/api/v1/products/search
      params do 
        requires :key_word, type: String
        optional :page_num, type: String
      end
      post 'search',jbuilder:'v1/products/index' do
        AppLog.info("key_word :#{params[:key_word]}")
        @category = Category.where("name like ?","%#{params[:key_word]}%").first
        AppLog.info("category:  #{@category.inspect}")
        @products = @category.products.state.sorted.by_page(params[:page_num]) if @category
        if @products.blank?
          @sub_category = SubCategory.where("name like ?","%#{params[:key_word]}%").first
          AppLog.info("sub_category:  #{@sub_category.inspect}")
          @products = @sub_category.products.state.sorted.by_page(params[:page_num]) if @sub_category
          if @products.blank?
            @detail_category = DetailCategory.where("name like ?","%#{params[:key_word]}%").first
            AppLog.info("detail_category:  #{@detail_category.inspect}")
            @products = @detail_category.products.state.sorted.by_page(params[:page_num]) if @detail_category
            @products = Product.state.where("name like ?","%#{params[:key_word]}%").sorted.by_page(params[:page_num]) if @products.blank?
          end
        end
      end

      # http://localhost:3000/api/v1/products/sub_category/:unique_id
      params do
        requires :unique_id, type: String
        optional :page_num, type: String
      end
      get "sub_category/:unique_id", jbuilder: 'v1/products/sub_category' do
        @sub_category = SubCategory.find_by(unique_id: params[:unique_id])
        if @sub_category
          @products = @sub_category.products.state.sorted.by_page(params[:page_num])
        end
      end
    end
  end
end
