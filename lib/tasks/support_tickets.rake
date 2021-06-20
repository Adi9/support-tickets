namespace :support_tickets do
  desc "Import new support tickets to the system, or return their count with COUNT_ONLY=1."
  task parse_new: :environment do
    count_only = !!ENV['COUNT_ONLY']
    puts SupportTicket.import_new_tickets(count_only)
  end

end
