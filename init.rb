# frozen_string_literal: true

configure do
  file = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
  file.sync = true
  use Rack::CommonLogger, file
end

Git.configure do |config|
  config.git_ssh = "#{settings.root}/ssh_script.sh"
end

Pronto::GemNames.new.to_a.each { |gem_name| require "pronto/#{gem_name}" }
