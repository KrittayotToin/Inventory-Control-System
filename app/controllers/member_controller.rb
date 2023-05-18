class MemberController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    # @members = Member.all
    @members = Member.paginate(page: params[:page], per_page: 10)
  end

 def all
  @members = Member.all

  respond_to do |format|
    format.html # Render HTML view (app/views/controller_name/all.html.erb)
    format.json { render json: @members } # Render JSON response
  end
end

  def show
    @member = Member.find(params[:id])
  end

  def member_names
    @member_list = Member.pluck(:id, :member_name )
    render json: @member_list

  end

  def new
    @member = Member.new
  end

  def create
    @member = Member.new(member_params)
    if @member.save
      flash[:success] = "Member successfully created"
      redirect_to member_path(@member)
    else
      flash[:error] = @member.errors.full_messages.join(', ')
      render :new
    end
  end
  

  def edit
    @member = Member.find(params[:id])

  end

  def update
    @member = Member.find(params[:id])
    if @member.update(member_params)
      flash[:success] = "member was successfully updated."
      redirect_to member_index_path
    else
      flash[:error] = "There was an error updating the member."
      render :edit
    end
  end
  

  def destroy

    @member = Member.find(params[:id])
        @member.destroy
    
        redirect_to member_index_path
  end
  

  private

  def member_params
    params.require(:member).permit(:member_code, :member_name, :member_phone, :member_email, :member_department)
  end
end
