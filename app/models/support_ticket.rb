class SupportTicket < ApplicationRecord
  include AASM

  require 'csv'

  has_many :active_admin_comments, as: :resource, class_name: "ActiveAdmin::Comment"

  validates :requester_name, presence: true
  validates :subject, presence: true
  validates :content, presence: true
  validates :requester_email, format: { with: Devise.email_regexp }

  scope :new_support_tickets, -> { where(status: 'new') }
  scope :pending_support_tickets, -> { where(status: 'pending') }
  scope :resolved_support_tickets, -> { where(status: 'resolved') }

  aasm column: :status do
    state :new, initial: true
    state :pending
    state :resolved

    event :set_state do
      transitions from: :new, to: :pending, if: :is_pending?
    end

    event :resolve do
      transitions from: :pending, to: :resolved
    end
  end

  def is_pending?
    # TODO: check if has comments
    self.active_admin_comments.count > 0
  end

  def dump_to_csv
    ret = false
    cfs = CsvFileStore.get_csv_file_store

    cfs.with_lock do
      begin
        cfs.lock_csv_file('a+') do |f|
          line_count = f.readlines.size
          # puts "SIZE: #{line_count}"
          if line_count == 0
            dump_csv_headers(f)
          end

          dump_csv_values(f)
        end

        ret = true
      rescue
      end
    end

    ret
  end

  # Imports new support tickets from csv
  # @returns: number of imported or found tickets
  def self.import_new_tickets(count_only = false)
    imported_count = 0
    cfs = CsvFileStore.get_csv_file_store

    cfs.with_lock do
      failed_rows = []
      file_opened = false

      begin
        cfs.lock_csv_file('a+') do |f| # lock for write so we're exclusive
          file_opened = true
          csv = CSV.parse(f, headers: true)

          if count_only
            imported_count = csv.count
          else
            csv.each_with_index do |row, i|
              st = SupportTicket.new(row.to_hash)
              if st.save
                imported_count += 1
              else
                failed_rows.push(row)
              end
            end
          end
        end
      rescue Exception => e
        Rails.logger.debug(e)
      end

      if !count_only && file_opened
        cfs.truncate!
        unless failed_rows.blank?
          cfs.lock_csv_file('a+') do |f|
            st = SupportTicket.new
            st.dump_csv_headers(f)
            failed_rows.each do |csv_row|
              f << csv_row
            end
          end
        end
      end
    end

    return imported_count
  end

  def dump_csv_headers(file)
    file << (exported_attributes.keys).join(',') + "\n"
  end

private

  def exported_attributes
    self.attributes.except("id", "status", "updated_at")
  end

  def dump_csv_values(file)
    if self.new_record?
      now = Time.now
      self.created_at = self.updated_at = now
    end
    file << (exported_attributes.values.collect{ |c| get_csv_field_string(c) }).join(',') + "\n"
  end

  def get_csv_field_string(value)
    value = begin
      # ActionController::Base.helpers.strip_tags(value.to_s)
      ActionView::Base.full_sanitizer.sanitize(value.to_s)
    rescue
      raise "Cannot sanitize value!"
    end

    value = value.gsub('"','\"')

    ['"', value, '"'].reject{|r| r.nil?}.join
  end

  # def self.lock_csv_file(openmode = 'r', lockmode = nil)
  #   filename = SUPPORT_TICKETS_CSV_PATH

  #   if openmode == 'r' || openmode == 'rb'
  #     lockmode ||= File::LOCK_SH
  #   else
  #     lockmode ||= File::LOCK_EX
  #   end

  #   value = nil

  #   open(filename, openmode) do |f|
  #     SupportTicket.flock(f, lockmode) do
  #       begin
  #         value = yield f
  #       ensure
  #         f.flock(File::LOCK_UN)
  #       end
  #     end

  #     return value
  #   end
  # end

  # def self.flock(file, mode)
  #   success = file.flock(mode)
  #   if success
  #     begin
  #       yield file
  #     ensure
  #       file.flock(File::LOCK_UN)
  #     end
  #   end

  #   return success
  # end

end
