class AddUserToSupportTickets < ActiveRecord::Migration[5.2]
  def change
    add_reference :support_tickets, :user, foreign_key: true
  end
end
