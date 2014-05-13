# encoding: utf-8

module ResqueRing
  # Methods dealing with pidfile management
  class PidFile < File
    @pid = nil

    def self.with_pid(pidfile)
      fail StandardError, "Pidfile is missing. Are you sure a ResqueRing
        process is running?" unless exists?(pidfile)
      yield(pid(pidfile)) if block_given? && pid(pidfile)
    rescue => e
      error "I'm sorry, Dave. I'm afraid I can't do that: #{e}"
    end

    def self.write(pidfile)
      open(pidfile, 'w') { |f| f.write(Process.pid) }
    rescue => e
      error "Error writing pidfile: #{e.class}: #{e}", true
    end

    def self.clean(pidfile)
      delete pidfile
    rescue
      error "Problem deleting pidfile '#{pidfile}'.
        Please delete it yourself.", true
    end

    def self.pid(pidfile)
      @pid ||= File.open(pidfile).read.strip.to_i
    end

    def self.error(message, critical = false)
      $stderr.puts message
      exit if critical
      false
    end
  end
end
