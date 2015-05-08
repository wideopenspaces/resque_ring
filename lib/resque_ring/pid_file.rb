# encoding: utf-8

module ResqueRing
  # Methods dealing with pidfile management
  class PidFile
    @pid = nil

    def self.with_pid(pidfile)
      fail StandardError, "Pidfile is missing. Are you sure a ResqueRing
        process is running?" unless exist?(pidfile)
      yield(pid(pidfile)) if block_given? && pid(pidfile)
    rescue => e
      error "I'm sorry, Dave. I'm afraid I can't do that: #{e}"
    end

    def self.write(pidfile)
      File.open(pidfile, 'w') { |f| f.write(Process.pid) }
    rescue => e
      error "Error writing pidfile: #{e.class}: #{e}", true
    end

    def self.clean(pidfile)
      File.delete pidfile
    rescue
      error "Problem deleting pidfile '#{pidfile}'.
        Please delete it yourself.", true
    end

    def self.pid(pidfile)
      @pid ||= File.open(pidfile).read.strip.to_i
    end

    def self.exist?(pidfile)
      File.exist?(pidfile)
    end

    def self.error(message, critical = false)
      $stderr.puts message
      exit if critical
      false
    end
  end
end
