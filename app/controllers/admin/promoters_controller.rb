class Admin::PromotersController < Admin::BaseController
  before_action :set_promoter, only: [:edit, :update, :destroy]
  
  def index
    @q = Promoter.ransack(params[:q])
    @promoters = @q.result.latest.page(params[:page])
  end

  def new
    @promoter = Promoter.new
  end

  def edit
  end

  def update
    image_params = params[:promoter][:image]
    if @promoter.update(promoter_params)     
      ImageUtil.image_upload(image_params,"Promoter",@promoter.id)
      return redirect_to session[:return_to] if session[:return_to]
      redirect_to admin_promoters_path
    else
      render 'edit' 
    end
  end

  def destroy
    @promoter.destroy
    redirect_to :back
  end

  def create
    image_params = params[:promoter][:image]
    @promoter = Promoter.new(promoter_params)
    if @promoter.save
      ImageUtil.image_upload(image_params,"Promoter",@promoter.id)
      redirect_to admin_promoters_path
    else
      render 'new'
    end
  end

  private 

    def image_upload(image_params,model_name,model_id)
      image_params.each do |img|
        Image.create(image:img,target_type:model_name,target_id:model_id)
      end
    end 

    def set_promoter
      @promoter = Promoter.find(params[:id])
    end

    def promoter_params
      params.require(:promoter).permit(:name, :phone, :id_card, :sex, :material)
    end
end
