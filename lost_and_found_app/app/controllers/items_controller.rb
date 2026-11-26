class ItemsController < ApplicationController
  ITEMS_PER_PAGE = 10

  before_action :require_login
  before_action :set_item, only: %i[ show edit update destroy ]
  before_action :require_staff, only: %i[ new edit create update destroy ]
  #lamdba function to check item have the same id with the staff
  before_action ->{ ensure_same_facility(@item)}, only: %i[edit update destroy]

  # GET /items or /items.json
  def index
    if current_user.staff?
      #staff can search and sort by category & status
      @items = Item.where(facility_id: current_user.facility_id)
                   .search(params[:query])
                   .by_category(params[:category])
                   .by_status(params[:status])
    else
      #general users can search and sort by facility & category
      @items = Item.available
                   .search(params[:query])
                   .by_facility(params[:facility_id])
                   .by_category(params[:category])
    end

    @sort = params[:sort] == "oldest" ? "oldest" : "newest"
    sort_direction = @sort == "oldest" ? :asc : :desc
    @items = @items.order(date_found: sort_direction, id: sort_direction)
    @total_pages = (@items.count.to_f / ITEMS_PER_PAGE).ceil
    @current_page = params[:page].to_s.to_i
    @current_page = 1 unless @current_page.positive?
    @current_page = [@current_page, [@total_pages, 1].max].min
    @items = @items.limit(ITEMS_PER_PAGE).offset((@current_page - 1) * ITEMS_PER_PAGE)
  end

  # GET /items/1 or /items/1.json
  def show
    if current_user.general? && !@item.available?
      respond_to do |format|
        format.html { redirect_to items_path, alert: "You can only view available items." }
        format.json { render json: { error: "You can only view available items." }, status: :forbidden }
      end
      return
    end

    if current_user.staff? && @item.facility_id != current_user.facility_id
      respond_to do |format|
        format.html { redirect_to items_path, alert: "Wrong facility." }
        format.json { render json: { error: "Wrong facility." }, status: :forbidden }
      end
      return
    end
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items or /items.json
  def create
    @item = Item.new(item_params)
    @item.facility_id = current_user.facility_id
    @item.status = :available

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: "Item was successfully created." }
        format.json { render :show, status: :created, location: @item }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @item.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    #update of item is triggered by update of claim
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: "Item was successfully updated.", 
        status: :see_other }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @item.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy!

    respond_to do |format|
      format.html { redirect_to items_path, notice: "Item was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.require(:item).permit(:title, :description, :category, :date_found)
    end
end
