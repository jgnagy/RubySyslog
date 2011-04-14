# This is some code I borrowed from the 'slick' chat server. Its a nice way to
# handle threadpools.
require 'thread'

# Usage
#   pool = ThreadPool.new(10)
#   begin
#     # ...
#     pool.add_job do
#       # ... happens in a thread ...
#     end # returns immediately, block is FIFO queued if no threads available
#     # ...
#   ensure
#     pool.stop
#   end

class ThreadPool
  # Used to determine the size of the thread pool.
  attr_reader :size

  def initialize(size)
    @work = Queue.new
    @group = ThreadGroup.new
    @shutdown = false
	@size = size
    size.times do
      Thread.new do
        @group.add(Thread.current)
        Thread.stop
        loop do
          if @shutdown
            #puts "#{Thread.current} stopping";
            Thread.current.terminate
          end
          job = @work.pop # threads wait here for a job
          args, block = *job
          begin
            block.call(*args)
          rescue StandardError => e
            bt = e.backtrace.join("\n")
            $stderr.puts "Error in thread (please catch this): #{e.inspect}\n#{bt}"
          end
          Thread.pass
        end
      end
    end
    @group.list.each { |w| w.run }
  end

  # Add a job to the queue
  def add_job(*args, &block)
    @work << [args, block]
    self
  end

  # Time to stop processing threads.
  def shutdown(wait=true)
    @group.enclose
    @shutdown = true
    @group.list.first.join until @group.list.empty? if wait
  end

  # Added to keep the script going in a loop
  def still_working?
    if !@work.empty? and !@group.list.empty?
      return true
    else
      return false
    end
  end
end
