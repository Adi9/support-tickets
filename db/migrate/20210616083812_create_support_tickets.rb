class CreateSupportTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :support_tickets do |t|
      t.string :requester_email
      t.string :requester_name
      t.string :status
      t.string :subject
      t.text :content

      t.timestamps
    end
  end
end
