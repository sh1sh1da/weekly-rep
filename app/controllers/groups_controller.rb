class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :validate_group_user, only: [:edit, :update, :destroy]
  before_action :check_belonging, only: [:new, :create]

  # GET /groups
  # GET /groups.json
  def index
    @groups = Group.all
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    set_reporting_time

    respond_to do |format|
      if current_user.update({ group: @group })
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    set_reporting_time

    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def group_params
    params.require(:group).permit(:name, :description, :template, :time, :day_of_week)
  end

  def validate_group_user
    return if current_user.group == @group
    flash[:alert] = '権限がありません'
    redirect_to action: 'index'
  end

  def check_belonging
    unless current_user.group_id.nil?
      flash[:alert] = 'すでにグループに所属済みです'
      redirect_to action: 'index'
    end
  end

  def set_reporting_time
    hour = group_params['time(4i)'].to_i
    min = group_params['time(5i)'].to_i
    wday = group_params['day_of_week'].to_i
    @group.set_reporting_time(hour, min, wday)
  end
end
