support_ticket_dsl = Proc.new do

  permit_params :requester_email, :requester_name, :subject, :content, :user_id

  collection_action :import_new_tickets, method: :post do
    imported_count = SupportTicket.import_new_tickets
    redirect_to admin_support_tickets_path, notice: "Successfully imported #{imported_count} support tickets"
  end

  action_item :import_tickets, only: :index do
    import_count = SupportTicket.import_new_tickets(true)
    if import_count > 0
      link_to "Import #{import_count} new ticket(s) from disk", import_new_tickets_admin_support_tickets_path, method: :post
    end
  end

  member_action :resolve_ticket, method: :post do
    notice = { notice: "Support Ticket #{resource.id} successfully resolved" }
    begin
      resource.resolve!
    rescue
      notice = { alert: "Set Support Tickets to `pending` state first, by adding at least one comment" }
    end
    redirect_to admin_support_tickets_path, notice
  end

  action_item :resolve_ticket, only: [:show] do
    link_to "Resolve Support Ticket", resolve_ticket_admin_support_ticket_path(resource.id), method: :post
  end

  actions :all, except: [:new, :create, :edit, :update]

  index do
    selectable_column
    id_column
    column :requester_email
    column :requester_name
    column :user
    column :status
    column :subject
    column :created_at
    column :updated_at

    actions do |support_ticket|
      if support_ticket.pending?
        link_to "Resolve", resolve_ticket_admin_support_ticket_path(support_ticket.id), method: :post
      end
    end
  end
end

ActiveAdmin.register SupportTicket do
  menu parent: 'Support Tickets', label: "All"

  instance_exec &support_ticket_dsl
end

ActiveAdmin.register SupportTicket, as: "NewSupportTicket" do
  menu parent: 'Support Tickets', label: "New"

  controller do
    def find_resource
      SupportTicket.new_support_tickets.find(params[:id])
    end

    def scoped_collection
      end_of_association_chain.new_support_tickets
    end
  end

  instance_exec &support_ticket_dsl
end

ActiveAdmin.register SupportTicket, as: 'PendingSupportTicket' do
  menu parent: 'Support Tickets', label: "Pending"

  controller do
    def find_resource
      SupportTicket.pending_support_tickets.find(params[:id])
    end

    def scoped_collection
      end_of_association_chain.pending_support_tickets
    end
  end

  instance_exec &support_ticket_dsl
end

ActiveAdmin.register SupportTicket, as: 'ResolvedSupportTicket' do
  menu parent: 'Support Tickets', label: "Resolved"

  controller do
    def find_resource
      SupportTicket.resolved_support_tickets.find(params[:id])
    end

    def scoped_collection
      end_of_association_chain.resolved_support_tickets
    end
  end

  instance_exec &support_ticket_dsl
end