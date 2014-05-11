# encoding: utf-8

module ResqueRing
  # Methods dealing with pidfile management
  class PidFile < File
    @pid = nil

    def self.with_existing_pid(pidfile)
      fail StandardError, "Pidfile is missing. Are you sure a ResqueRing
        process is running?" unless exists?(pidfile)
      # pid = pid(pidfile)
      yield(pid(pidfile)) if block_given? && pid(pidfile)
    rescue => e
      $stderr.puts "I'm sorry, Dave. I'm afraid I can't do that: #{e}"
    end

    def self.write(pidfile)
      open(pidfile, 'w') { |f| f.write(Process.pid) }
      at_exit { clean(pidfile) }
    rescue => e
      $stderr.puts "Error writing pidfile: #{e.class}: #{e}"
      exit
    end

    def self.clean(pidfile)
      delete pidfile
    rescue
      $stderr.puts "Problem deleting pidfile '#{pidfile}'.
        Please delete it yourself."
      exit
    end

    def self.pid(pidfile)
      @pid ||= File.open(pidfile).read.strip.to_i
    end
  end
end
