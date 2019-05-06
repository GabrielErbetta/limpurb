# frozen_string_literal: true

require 'git'
require 'logger'
require 'pronto'
require 'sinatra'
require_relative 'init'
require_relative 'helpers'

# For checking if the api is alive
get '/status' do
  'ok'
end

# Sweeps the pull request for linter warnings
post '/sweep' do
  payload = json_params

  repo_owner = payload['repository']['owner']['login']
  repo_name  = payload['repository']['name']
  pr_number  = payload['number']
  pr_base    = payload['pull_request']['base']['ref']

  case payload['action']
  when 'opened'
    Thread.new do
      process_opened_pr(repo_owner, repo_name, pr_number, pr_base)
    end
  when 'synchronize'
    Thread.new do
      process_synchronize_pr repo_owner, repo_name, pr_number, pr_base
    end
  end

  halt 200
end
