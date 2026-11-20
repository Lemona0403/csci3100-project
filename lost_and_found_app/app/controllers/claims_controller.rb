class ClaimsController < ApplicationController
  before_action :set_item
  before_action :set_claim, only: %i[ show edit update destroy ]
  before_action :require_login
  before_action :require_staff, only: %i[ edit update destroy ]
  #lamdba function to check claim have the same id with the staff
  before_action -> { ensure_same_facility(@claim) }, only: %i[ edit update destroy ]

  # GET /claims or /claims.json
  def index
    if current_user.staff?
      @claims = Claim.where(facility_id: current_user.facility_id)
    else
      @claims = Claim.where(user_id: current_user.id) 
    end
  end

  # GET /claims/1 or /claims/1.json
  def show
  end

  # GET /claims/new
  def new
    #Get the id of an item before creating a claim for that item
    @item = Item.find(params[:item_id])
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

    saved = false
    #Set up transaction so that save fails if submit_claim! returns error
    ActiveRecord::Base.transaction do
      @claim.save!
      @item.submit_claim! #item status available to claim-pending when creating new claims
      saved = true
    end

    respond_to do |format|
      if saved
        format.html { redirect_to @claim, notice: "Claim was successfully created." }
        format.json { render :show, status: :created, location: @claim }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @claim.errors, status: :unprocessable_content }
      end
    end

  end

  # PATCH/PUT /claims/1 or /claims/1.json
  def update
    #get the status user want to change
    target_status = claim_params[:status]
    updated = false
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

    respond_to do |format|
      if updated
        format.html { redirect_to @claim, notice: "Claim was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @claim }
      else
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
      #redirect_to ,alert: 'Item not found' 
    end
    
    def set_claim
      @claim = Claim.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      #redirect_to ,alert: 'Claim not found'
    end

    # Only allow a list of trusted parameters through.
    def claim_params
      params.require(:claim).permit(:contact_info, :message)
    end
end
