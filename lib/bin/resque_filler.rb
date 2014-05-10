# Utility class for filling up resque with meaningless data
class ResqueFiller
  def self.fill(number_entries = 100)
    number_entries.times do |i|
      Resque.enqueue(ResqueEmptier, i)
    end
  end
end
