class SupportTicketsController < ApplicationController

  # cancan
  load_and_authorize_resource # param_method: :support_ticket_params

  USER_METHODS = [:show, :edit, :update, :destroy]

  before_action :authenticate_user!, only: USER_METHODS
  before_action :set_support_ticket, only: USER_METHODS


  # GET /support_tickets
  # GET /support_tickets.json
  def index
    @support_tickets = current_user.nil? ? nil : current_user.support_tickets
    @logged_in_user = current_user.nil? ? nil : current_user.id
  end

  # GET /support_tickets/1
  # GET /support_tickets/1.json
  def show
  end

  # GET /support_tickets/new
  def new
    if current_user.nil?
      @support_ticket = SupportTicket.new
    else
      @support_ticket = current_user.support_tickets.new
      @logged_in_user = current_user.id
    end
  end

  # GET /support_tickets/1/edit
  def edit
  end

  # POST /support_tickets
  # POST /support_tickets.json
  def create
    @support_ticket = SupportTicket.new(support_ticket_params)

    respond_to do |format|
      if @support_ticket.dump_to_csv
        format.html { redirect_to new_support_ticket_path, notice: 'Support ticket was successfully created.' }
        # format.json { render :show, status: :created, location: @support_ticket }
      else
        flash[:alert] = "Form was sent with invalid values."
        format.html { render :new }


          # error: 'Form has invalid fields. Please correct them and try again.' }
        # format.json { render json: @support_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /support_tickets/1
  # PATCH/PUT /support_tickets/1.json
  def update
    respond_to do |format|
      if @support_ticket.update(support_ticket_params)
        format.html { redirect_to @support_ticket, notice: 'Support ticket was successfully updated.' }
        format.json { render :show, status: :ok, location: @support_ticket }
      else
        format.html { render :edit }
        format.json { render json: @support_ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /support_tickets/1
  # DELETE /support_tickets/1.json
  def destroy
    @support_ticket.destroy
    respond_to do |format|
      format.html { redirect_to support_tickets_url, notice: 'Support ticket was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_support_ticket
      @support_ticket = SupportTicket.find(params[:id])
      @logged_in_user = current_user.id
    end

    # Only allow a list of trusted parameters through.
    def support_ticket_params
      params.require(:support_ticket).permit(
        :requester_email,
        :requester_name,
        :status,
        :subject,
        :content,
        :user_id
      )
    end
end
