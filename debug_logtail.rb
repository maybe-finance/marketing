#!/usr/bin/env ruby

require 'bundler/setup'
require 'logtail-rails'

# Try to load dotenv if available (development/test environments)
begin
  require 'dotenv'
  Dotenv.load if defined?(Dotenv)
rescue LoadError
  # dotenv not available - this is normal in production
end

puts "🔍 Debugging Logtail Configuration"
puts "=================================="

# Check environment variables
api_key = ENV["LOGTAIL_API_KEY"]
ingesting_host = ENV["LOGTAIL_INGESTING_HOST"]

puts "Environment Variables:"
puts "  LOGTAIL_API_KEY: #{api_key ? "Present (#{api_key[0..8]}...)" : "❌ Missing"}"
puts "  LOGTAIL_INGESTING_HOST: #{ingesting_host || "❌ Missing"}"
puts

if api_key.nil? || ingesting_host.nil?
  puts "❌ Missing required environment variables. Common values:"
  puts "   LOGTAIL_INGESTING_HOST should be:"
  puts "   - https://in.logs.betterstack.com (US)"
  puts "   - https://in.logs.eu.betterstack.com (EU)"
  exit 1
end

# Test basic connectivity
puts "🌐 Testing Network Connectivity to #{ingesting_host}..."
begin
  require 'net/http'
  require 'uri'

  uri = URI(ingesting_host)
  response = Net::HTTP.get_response(uri)
  puts "   Status: #{response.code} #{response.message}"
rescue => e
  puts "   ❌ Network Error: #{e.message}"
  puts "   This could explain why Logtail threads are stuck!"
end

puts

# Test Logtail logger creation
puts "🧪 Testing Logtail Logger Creation..."
begin
  logger = Logtail::Logger.create_default_logger(api_key, ingesting_host: ingesting_host)
  puts "   ✅ Logger created successfully"

  puts "🧪 Testing Log Message..."
  logger.info("Test message from debug script", { test: true, timestamp: Time.now })
  puts "   ✅ Log message sent"

  puts "🧪 Closing logger to flush messages..."
  logger.close
  puts "   ✅ Logger closed"

rescue => e
  puts "   ❌ Error: #{e.message}"
  puts "   Backtrace:"
  e.backtrace.first(5).each { |line| puts "     #{line}" }
end

puts
puts "✅ Debug complete. Check your Better Stack dashboard for the test message."
