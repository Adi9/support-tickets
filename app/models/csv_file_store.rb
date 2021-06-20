class CsvFileStore < ApplicationRecord

  validates :url, presence: true

  def lock_csv_file(openmode = 'r', lockmode = nil)
    filename = self.url

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
          f.flock(File::LOCK_UN) # is this second unlock needed?
        end
      end

      return value
    end
  end

  def truncate!
    self.lock_csv_file do |f|
      File.truncate(f, 0)
    end
  end

  def self.get_csv_file_store
    cfs = CsvFileStore.first
    raise "System not setup." if cfs.nil?
    cfs
  end

private

  def flock(file, mode)
    success = file.flock(mode)
    if success
      begin
        yield file
      ensure
        file.flock(File::LOCK_UN) # is this second unlock needed?
      end
    end

    return success
  end
end
