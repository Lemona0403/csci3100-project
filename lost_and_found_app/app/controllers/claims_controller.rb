class ClaimsController < ApplicationController
  before_action :set_item, only: %i[ new create ]
  before_action :set_claim, only: %i[ show edit update destroy ]
  before_action :require_login
  before_action :require_staff, only: %i[ edit update destroy ]
  #lamdba function to check claim have the same id with the staff
  before_action -> { ensure_same_facility(@claim) }, only: %i[ edit update destroy ]

  # GET /claims or /claims.json
  def index
    if current_user.staff?
      @claims = Claim.where(facility_id: current_user.facility_id).pending_first
    else
      @claims = Claim.where(user_id: current_user.id) 
    end
    @claims = @claims.search(params[:query]).by_status(params[:status])
  end

  # GET /claims/1 or /claims/1.json
  def show
    unless can_view_claim?(@claim)
      respond_to do |format|
        format.html { redirect_to claims_path, alert: "You cannot view other users' claims." }
        format.json { render json: { error: "You cannot view other users' claims." }, 
                      status: :forbidden }
      end
      return
    end
  end

  # GET /claims/new
  def new
    unless @item.available?
      respond_to do |format|
        format.html { redirect_to items_path, alert: "The item is not available" }
        format.json { render json: { error: "The item is not available" }, 
                      status: :unprocessable_content }
      end
      return
    end
    # new sets item_id foreign key automatically
    @claim ||= @item.claims.new
  end

  # GET /claims/1/edit
  def edit
  end

  # POST /claims or /claims.json
  def create
    @item = Item.find(params[:item_id])
    # build sets the item_id foreign key automatically (@item has many claims)
    @claim = @item.claims.build(claim_params)
  
    @claim.user_id = current_user.id
    @claim.facility_id = @item.facility_id
    @claim.status = :pending
    
    #ban users submit claim for non available claim
    unless @item.available?
      respond_to do |format|
      format.html { redirect_to @item, alert: "The item is not available" }
      format.json { render json: { error: "The item is not available" }, 
                    status: :unprocessable_content }
      end
      return
    end
    
    saved = false
    error_message = nil
    #Set up transaction so that save fails if submit_claim! returns error
    begin
      ActiveRecord::Base.transaction do
      @claim.save!
      @item.submit_claim! #item status available to claim-pending when creating new claims
      saved = true
      end
    rescue StandardError => e
      #stop when either @claim.save! or @item.submit_claim! fails
      error_message = e.message
      saved = false
    end

    respond_to do |format|
      if saved
        format.html { redirect_to @claim, notice: "Claim was successfully created." }
        format.json { render :show, status: :created, location: @claim }
      else
        flash.now[:alert] = error_message if error_message
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: { errors: @claim.errors, message: error_message }, 
        status: :unprocessable_content }
      end
    end

  end

  # PATCH/PUT /claims/1 or /claims/1.json
  def update
    #get the status user want to change
    target_status = claim_params_for_update[:status]
    updated = false
    error_message = nil

    begin
      ActiveRecord::Base.transaction do
        case target_status
        when "approved"
          #approve claim, then item status become claimed
          @claim.approve!
          @claim.item.approve_claim!
        when "rejected"
          #reject claim, then item status become available
          @claim.reject!
          @claim.item.reject_claim!
        else
          @claim.update!(claim_params)
        end
      updated = true
      end
    rescue StandardError => e
      #remain pending when either approve! or reject! fails
      error_message = e.message
      updated = false 
    end 

    respond_to do |format|
      if updated
        format.html { redirect_to @claim, notice: "Claim was successfully updated.", 
        status: :see_other }
        format.json { render :show, status: :ok, location: @claim }
      else
        flash.now[:alert] = error_message if error_message
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @claim.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /claims/1 or /claims/1.json
  def destroy
    @claim.destroy!

    respond_to do |format|
      format.html { redirect_to claims_path, notice: "Claim was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:item_id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to items_path, alert: "Item not found." }
        format.json { render json: { error: "Item not found." }, status: :not_found }
      end
    end
    
    def set_claim
      @claim = Claim.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      respond_to do |format|
        format.html { redirect_to claims_path, alert: "Claim not found." }
        format.json { render json: { error: "Claim not found." }, status: :not_found }
      end
    end

    # Only allow a list of trusted parameters through.
    def claim_params
      params.require(:claim).permit(:contact_info, :message)
    end

    def claim_params_for_update
      params.require(:claim).permit(:contact_info, :message, :status)
    end

    def can_view_claim?(claim)
      if current_user.staff? && claim.facility_id == current_user.facility_id
        return true
      elsif current_user.general? && claim.user_id == current_user.id
        return true
      else
        return false
      end
    end
end
