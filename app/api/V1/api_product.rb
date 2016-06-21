module V1
  class ApiProduct < Grape::API

    version 'v1', using: :path

    resources 'products' do

      # http://localhost:3000/api/v1/products/:unique_id
      params do
        requires :unique_id, type: String
        optional :token, type: String
        optional :message_id, type: String
      end
      get ":unique_id", jbuilder: 'v1/products/show' do
        @product = Product.find_by(unique_id:params[:unique_id])
        if @token.present?
          @favorite = @user.favorites.find_by(product_id: @product.try(:id))
          if params[:message_id]
            message = Message.normal.find_by(id: params[:message_id])
            message.read! if message.present?
          end
        end
      end

      #http://localhost:3000/api/v1/products/search
      params do 
        requires :key_word, type: String
        optional :token, type: String
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
            @products, @total_pages = Product.search_with_name_like(params[:key_word], params[:page_num]) if @products.blank?
          end
        end
      end

      #http://localhost:3000/api/v1/products/search_name
      params do 
        requires :key_word, type: String
        optional :token, type: String
        optional :page_num, type: String
      end
      post 'search_name',jbuilder:'v1/products/index' do
        AppLog.info("key_word :#{params[:key_word]}")
        @products, @total_pages = Product.search_with_name_like(params[:key_word], params[:page_num])
      end

      # http://localhost:3000/api/v1/products/sub_category/:unique_id
      params do
        requires :unique_id, type: String
        optional :token, type: String
        optional :page_num, type: String
      end
      get "sub_category/:unique_id", jbuilder: 'v1/products/sub_category' do
        @sub_category = SubCategory.find_by(unique_id: params[:unique_id])
        if @sub_category
          @products = @sub_category.products.state.sorted.by_page(params[:page_num])
        end
      end

      # http://localhost:3000/api/v1/products/product_bar_codes/:bar_code
      params do
        requires :bar_code, type: String
      end
      get "search_bar_code/:bar_code", jbuilder: 'v1/products/search_bar_code' do
        bar_code = BarCode.find_by(bar_code_no: params[:bar_code])
        @product = bar_code.try(:product)
      end

      #http://localhost:3000/api/v1/products/search_name_to_bar_code
      params do 
        requires :key_word, type: String
        optional :page_num, type: String
      end
      post 'search_name_to_bar_code',jbuilder:'v1/products/search_name_to_bar_code' do
        @products, @total_pages = Product.search_with_name_like(params[:key_word], params[:page_num])
      end

      # http://localhost:3000/api/v1/products/create_bar_code
      params do
        requires :unique_id, type: String
        requires :bar_code_no, type: String
      end
      post "create_bar_code", jbuilder: 'v1/products/create_bar_code' do
        @product = Product.find_by(unique_id: params[:unique_id])
        @bar_code = @product.bar_codes.where(bar_code_no: params[:bar_code_no]).first_or_create if @product
      end

      # http://localhost:3000/api/v1/products/delete_bar_code
      params do
        requires :unique_id, type: String
        requires :bar_code_no, type: String
      end
      delete "delete_bar_code", jbuilder: 'v1/products/delete_bar_code' do
        @product = Product.find_by(unique_id: params[:unique_id])
        bar_code = @product.bar_codes.find_by(bar_code_no: params[:bar_code_no]) if @product
        @result = bar_code.destroy if bar_code
      end
    end
  end
end
