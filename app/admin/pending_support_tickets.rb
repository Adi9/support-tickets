ActiveAdmin.register SupportTicket, as: 'PendingSupportTicket' do

  actions :all, except: [:new, :create, :edit, :update]

  menu parent: 'Support Tickets', label: "Pending"

  controller do

    def find_resource
      SupportTicket.pending_support_tickets.find(params[:id])
    end

    def scoped_collection
      end_of_association_chain.pending_support_tickets
    end

    # def create
    #   super do |format|
    #     redirect_to collection_url and return if resource.valid?
    #   end
    # end

    # def update
    #   super do |format|
    #     redirect_to collection_url and return if resource.valid?
    #   end
    # end
  end
end