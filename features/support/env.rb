require 'cucumber/formatter/unicode' # Remove this line if you don't want Cucumber Unicode support
require 'pry'

require 'rack'
require 'rack/test'
require File.dirname(__FILE__) + "/../fixtures/fake_app"

require 'cucumber/api_steps'

def app
  Rack::Lint.new(CucumberApiSteps::FakeApp.new)
end

Thread.new {
  Rack::Server.start(app: app, Port: 3921)
}
sleep 1
puts "Continuing"

Before do
  url "http://localhost:3921"
end

Before("@digest-auth") do
  def app
    app = Rack::Auth::Digest::MD5.new(CucumberApiSteps::FakeApp.new) do |username|
      { 'joe' => 'god' }[username]
    end
    app.realm = 'TestApi'
    app.opaque = 'this-should-be-secret'
    app
  end
end
