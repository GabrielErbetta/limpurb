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

# Sweeps the git repo
post '/sweep' do
  payload = json_params
  halt 200 unless %w[opened synchronize].include? payload['action']

  repo_owner = payload['repository']['owner']['login']
  repo_name  = payload['repository']['name']
  pr_number  = payload['number']
  pr_base    = payload['pull_request']['base']['ref']

  repo = load_git_repo repo_owner, repo_name

  if payload['action'] == 'opened'
    # fetch branch
    # checkout to branch
    # run pronto to master

    repo.fetch('origin')
    repo.branch("origin/#{pr_base}").checkout
    repo.branch("pr-#{pr_number}").checkout
    repo.pull('origin', "pull/#{pr_number}/head")

    ENV['PRONTO_PULL_REQUEST_ID'] = pr_number
    Pronto.run(pr_base, "repos/#{repo_owner}/#{repo_name}", pronto_formatters)
  elsif payload['action'] == 'synchronize'
    # save current HEAD
    # checkout to branch
    # update branch
    # run pronto to HEAD
  end

  payload.inspect
end
