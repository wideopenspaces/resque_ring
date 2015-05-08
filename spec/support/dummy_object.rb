require 'resque_ring/utilities/signal_handler'

class DummyObject
  extend ResqueRing::Utilities::SignalHandler

  def self.signal_handler(signal = nil)
    signal
  end

  def self.hupty_hup(signal = nil)
    "Do the Hupty Hup!"
  end

  def self.quit_it(signal = nil)
    "Quitters never win."
  end
end
