# Temporary debug initializer for Logtail thread monitoring
# Remove this file once the issue is resolved

Rails.application.config.after_initialize do
  if defined?(Logtail) && Rails.logger.is_a?(Logtail::Logger)
    puts "🔍 Monitoring Logtail threads after Rails initialization..."

    # Check for Logtail threads
    logtail_threads = Thread.list.select do |thread|
      thread.backtrace_locations&.any? { |loc| loc.path.include?("logtail") }
    end

    if logtail_threads.any?
      puts "   Found #{logtail_threads.count} Logtail threads:"
      logtail_threads.each_with_index do |thread, i|
        puts "   Thread #{i + 1}: #{thread.status} - #{thread.backtrace_locations&.first}"
      end

      # Schedule a thread check after 10 seconds
      Thread.new do
        sleep 10
        puts "🔍 Thread status after 10 seconds:"
        logtail_threads.each_with_index do |thread, i|
          if thread.alive?
            puts "   Thread #{i + 1}: #{thread.status}"
            if thread.status == "sleep"
              puts "     ⚠️  Thread is sleeping - possible connectivity issue"
            end
          else
            puts "   Thread #{i + 1}: ❌ Dead"
          end
        end
      end
    else
      puts "   ✅ No Logtail threads found"
    end
  else
    puts "⚠️  Logtail logger not configured or not detected"
  end
end
