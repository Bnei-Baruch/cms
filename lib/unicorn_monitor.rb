SLEEP_TIME = 20
WORKER_MEMORY_LIMIT = 500_000 # MB
RESTART_EACH = 60 # minutes

class UnicornMonitor
  def self.start
    puts "#{Time.now} / Starting Unicorn Monitor Daemon"

    loop do
      #begin
	test_memory_consumption
	periodical_restart
      #rescue Exception => e
        #puts "#{Time.now} / Got error: #{e.message}"
      #end
      sleep(SLEEP_TIME)      
    end
  end

  def self.stop
    puts "#{Time.now} / Stopping Unicorn Monitor Daemon"
  end

  def self.test_memory_consumption
    lines = `ps -e -www -o pid,rss,command | grep '[u]nicorn_rails worker'`.split("\n")
    lines.each do |line|
      parts = line.split(' ')
      if parts[1].to_i > WORKER_MEMORY_LIMIT
        puts "#{Time.now} / Killing [memory limit] Unicorn worker with pid #{parts[0].to_i}"
        ::Process.kill('QUIT', parts[0].to_i)
      end
    end
  end

  def self.periodical_restart
    lines = `ps -e -www -o pid,etime,command | grep '[u]nicorn_rails worker'`.split("\n")
    lines.each do |line|
      parts = line.strip.split(/\s+/)
      pid = parts[0].to_i
      time = parts[1].split(':').reverse
      elapsed_time = time[2].to_i * 60 * 60 + time[1].to_i * 60 + time[0].to_i
      if elapsed_time > RESTART_EACH*60
        puts "#{Time.now} / Killing [periodical] Unicorn worker with pid #{pid}"
        ::Process.kill('QUIT', pid)
      end
    end
  end
end
