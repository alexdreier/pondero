# frozen_string_literal: true

# Enterprise Performance Testing Helpers
# Microsoft-level performance testing utilities

module PerformanceTestHelpers
  # Database Performance
  def expect_efficient_database_queries(max_queries: 10)
    query_count = 0
    query_time = 0
    
    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, start, finish, _id, payload|
      query_count += 1
      query_time += (finish - start)
      
      # Log slow queries for enterprise monitoring
      if (finish - start) > 0.1 # 100ms
        Rails.logger.warn "Slow query detected: #{payload[:sql]} (#{(finish - start).round(3)}s)"
      end
    end
    
    result = yield
    
    ActiveSupport::Notifications.unsubscribe(subscription)
    
    expect(query_count).to be <= max_queries, 
           "Expected <= #{max_queries} queries, got #{query_count}"
    expect(query_time).to be < 1.0, 
           "Expected total query time < 1s, got #{query_time.round(3)}s"
    
    result
  end

  def expect_no_n_plus_one_queries
    expect_efficient_database_queries(max_queries: 5) do
      yield
    end
  end

  # Memory Performance
  def expect_memory_efficiency(max_memory_mb: 50)
    memory_before = get_memory_usage
    
    result = yield
    
    memory_after = get_memory_usage
    memory_used = memory_after - memory_before
    
    expect(memory_used).to be < max_memory_mb, 
           "Expected memory usage < #{max_memory_mb}MB, used #{memory_used.round(2)}MB"
    
    result
  end

  def profile_memory_usage(&block)
    report = MemoryProfiler.report(&block)
    
    {
      total_allocated: report.total_allocated_memsize,
      total_retained: report.total_retained_memsize,
      objects_allocated: report.total_allocated,
      objects_retained: report.total_retained
    }
  end

  # Response Time Performance
  def expect_fast_response(max_time: 2.0)
    start_time = Time.current
    
    result = yield
    
    elapsed_time = Time.current - start_time
    expect(elapsed_time).to be < max_time,
           "Expected response time < #{max_time}s, got #{elapsed_time.round(3)}s"
    
    result
  end

  def benchmark_action(description = "Action")
    result = Benchmark.measure do
      yield
    end
    
    Rails.logger.info "#{description} Performance: #{result.real.round(3)}s real, #{result.total.round(3)}s CPU"
    
    {
      real: result.real,
      cpu: result.total,
      user: result.utime,
      system: result.stime
    }
  end

  # Page Load Performance
  def expect_fast_page_load(max_time: 3.0)
    start_time = Time.current
    
    yield
    
    # Wait for page to fully load
    expect(page).to have_css('body')
    
    load_time = Time.current - start_time
    expect(load_time).to be < max_time,
           "Expected page load < #{max_time}s, got #{load_time.round(3)}s"
  end

  def measure_first_contentful_paint
    # This would typically use browser performance APIs
    start_time = Time.current
    
    yield
    
    # Simple approximation - in real implementation would use
    # Performance Observer API or similar
    Time.current - start_time
  end

  # Asset Performance
  def expect_optimized_assets
    # Check CSS file sizes
    css_files = Dir[Rails.root.join('public/assets/*.css')]
    css_files.each do |file|
      size_mb = File.size(file) / 1024.0 / 1024.0
      expect(size_mb).to be < 1.0, "CSS file #{File.basename(file)} is #{size_mb.round(2)}MB (max: 1MB)"
    end

    # Check JS file sizes
    js_files = Dir[Rails.root.join('public/assets/*.js')]
    js_files.each do |file|
      size_mb = File.size(file) / 1024.0 / 1024.0
      expect(size_mb).to be < 2.0, "JS file #{File.basename(file)} is #{size_mb.round(2)}MB (max: 2MB)"
    end
  end

  def expect_compressed_assets
    # Check for gzip compression
    if Rails.env.production?
      css_files = Dir[Rails.root.join('public/assets/*.css.gz')]
      js_files = Dir[Rails.root.join('public/assets/*.js.gz')]
      
      expect(css_files).not_to be_empty, "No gzipped CSS assets found"
      expect(js_files).not_to be_empty, "No gzipped JS assets found"
    end
  end

  # Caching Performance
  def expect_cache_utilization(cache_key)
    # Clear cache first
    Rails.cache.delete(cache_key)
    
    # First call should miss cache
    first_time = Benchmark.measure do
      yield
    end
    
    # Second call should hit cache
    second_time = Benchmark.measure do
      yield
    end
    
    # Cache hit should be significantly faster
    expect(second_time.real).to be < (first_time.real * 0.5),
           "Cache hit (#{second_time.real.round(3)}s) should be faster than miss (#{first_time.real.round(3)}s)"
  end

  # Scalability Testing
  def simulate_concurrent_users(user_count: 10, &block)
    threads = []
    results = []
    
    user_count.times do |i|
      threads << Thread.new do
        # Create isolated test environment for each thread
        ActiveRecord::Base.connection_pool.with_connection do
          begin
            result = instance_eval(&block)
            results << { success: true, result: result }
          rescue => e
            results << { success: false, error: e.message }
          end
        end
      end
    end
    
    threads.each(&:join)
    
    success_count = results.count { |r| r[:success] }
    expect(success_count).to eq(user_count),
           "Expected all #{user_count} concurrent operations to succeed, #{success_count} succeeded"
    
    results
  end

  def stress_test_endpoint(path, requests: 100, concurrent: 10)
    require 'net/http'
    require 'uri'
    
    uri = URI.parse("http://localhost:3000#{path}")
    
    results = simulate_concurrent_users(user_count: concurrent) do
      times = []
      (requests / concurrent).times do
        start_time = Time.current
        
        Net::HTTP.get_response(uri)
        
        times << Time.current - start_time
      end
      times
    end
    
    all_times = results.select { |r| r[:success] }.flat_map { |r| r[:result] }
    
    {
      avg_response_time: all_times.sum / all_times.size,
      max_response_time: all_times.max,
      min_response_time: all_times.min,
      success_rate: results.count { |r| r[:success] } / results.size.to_f
    }
  end

  private

  def get_memory_usage
    # Get memory usage in MB
    `ps -o rss= -p #{Process.pid}`.to_i / 1024.0
  rescue
    0.0
  end
end