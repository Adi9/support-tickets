ActiveAdmin.register SupportTicket do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :requester_email, :requester_name, :subject, :content
  #
  # or
  #
  # permit_params do
  #   permitted = [:requester_email, :requester_name, :status, :subject, :content]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  menu parent: 'Support Tickets', label: "All"

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
    column :status
    column :subject
    column :created_at
    column :updated_at

    actions do |support_ticket|
      unless support_ticket.resolved?
        link_to "Resolve", resolve_ticket_admin_support_ticket_path(support_ticket.id), method: :post
      end
    end
  end

end
