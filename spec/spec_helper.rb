ENV["RAILS_ENV"]="test"

dir = File.dirname(__FILE__)
$LOAD_PATH.unshift dir + "/../lib"
$LOAD_PATH.unshift dir

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

require 'rubygems'
require 'rspec'
require 'database_cleaner'
require 'logger'
require 'record_cache'
require 'record_cache/test/resettable_version_store'

require 'test_after_commit'

# spec support files
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}

# logging
Dir.mkdir(dir + "/log") unless File.exists?(dir + "/log")
ActiveRecord::Base.logger = Logger.new(dir + "/log/debug.log")
# ActiveRecord::Base.logger = Logger.new(STDOUT)

# SQL Lite
ActiveRecord::Base.configurations = YAML::load(IO.read(dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(ENV["DATABASE_ADAPTER"] || "sqlite3")

# Initializers + Model + Data
load(dir + "/initializers/record_cache.rb")
load(dir + "/db/schema.rb")
Dir["#{dir}/models/*.rb"].each {|f| load(f) }
load(dir + "/db/seeds.rb")

# Clear cache after each test
RSpec.configure do |config|
  config.disable_monkey_patching!
  config.color = true

  config.before(:each) do
    RecordCache::Base.enable
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
    RecordCache::Base.version_store.reset!
  end
end
