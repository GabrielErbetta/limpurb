# frozen_string_literal: true

require 'git'
require 'logger'
require 'pronto'
require 'sinatra'
require_relative 'config'
require_relative 'helpers'

# For checking if the api is alive
get '/status' do
  'ok'
end

# Sweeps the git repo
post '/sweep' do
  payload = json_params
  halt 200 unless payload['action'].in? %w[opened synchronize]

  repo_owner = payload['repository']['owner']['login']
  repo_name  = payload['repository']['full_name']
  pr_number  = payload['number']
  pr_base    = payload['pull_request']['base']['ref']

  repo = load_git_repo repo_owner, repo_name

  if payload['action'] == 'opened'
    # fetch branch
    # checkout to branch
    # run pronto to master

    repo.fetch('origin', ref: "#{pr_base}:origin/#{pr_base}")
    repo.fetch('origin', ref: "pull/#{pr_number}/head:#{pr_number}")
    repo.branch('pr-2050').checkout
    Pronto.run('origin/master', '.', pronto_formatters)
  elsif payload['action'] == 'synchronize'
    # save current HEAD
    # checkout to branch
    # update branch
    # run pronto to HEAD
  end

  payload.inspect
end
