class SupportTicket < ApplicationRecord
  include AASM

  validates :requester_name, presence: true
  validates :requester_email, format: { with: Devise.email_regexp }

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
  end

  def dump_to_csv
    begin
      lock_csv_file('a+') do |f|
        line_count = f.readlines.size
        # puts "SIZE: #{line_count}"
        if line_count == 0
          dump_csv_headers(f)
        end

        dump_csv_values(f)
      end

      return true
    rescue
      return false
    end
  end

private

  def exported_attributes
    self.attributes.except("id", "status", "updated_at")
  end

  def dump_csv_headers(file)
    file << (exported_attributes.keys).join(',') + "\n"
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

    ['"', value.gsub('"','\"'), '"'].reject{|r| r.nil?}.join
  end

  def lock_csv_file(openmode = 'r', lockmode = nil)
    filename = SUPPORT_TICKETS_CSV_PATH

    if openmode == 'r' || openmode == 'rb'
      lockmode ||= File::LOCK_SH
    else
      lockmode ||= File::LOCK_EX
    end

    value = nil

    open(filename, openmode) do |f|
      flock(f, lockmode) do
        begin
          value = yield f
        ensure
          f.flock(File::LOCK_UN)
        end
      end

      return value
    end
  end

  def flock(file, mode)
    success = file.flock(mode)
    if success
      begin
        yield file
      ensure
        file.flock(File::LOCK_UN)
      end
    end

    return success
  end

end
