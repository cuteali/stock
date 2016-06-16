module V1
  class ApiMessage < Grape::API

    version 'v1', using: :path

    resources 'messages' do
      # http://localhost:3000/api/v1/messages
      params do
        requires :token, type: String
        optional :page_num, type: String
      end
      get '', jbuilder: 'v1/messages/index' do
        if @token.present?
          @messages = @user.messages.normal.latest.by_page(params[:page_num])
        end
      end

      #http://localhost:3000/api/v1/messages
      params do 
        requires :token, type: String
        requires :message_id, type: String
      end
      delete '', jbuilder: 'v1/messages/delete' do
        if @token.present?
          message = @user.messages.normal.find_by(id: params[:message_id])
          @message = message.deleted! if message.present?
        end
      end

      #http://localhost:3000/api/v1/messages/delete_all
      params do 
        requires :token, type: String
      end
      get 'delete_all', jbuilder: 'v1/messages/delete_all' do
        if @token.present?
          messages = @user.messages.normal
          @messages = messages.map{|m| m.deleted!} if messages.present?
        end
      end
    end
  end
end
