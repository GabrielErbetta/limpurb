# frozen_string_literal: true

require 'sinatra'
require_relative 'helpers'

setup_git

get '/status' do
  'ok'
end

post '/sweep' do
  payload = json_params
  halt 200 unless payload['action'].in? %w[opened synchronize]

  if payload['action'] == 'opened'
    # fetch branch
    # checkout to branch
    # run pronto to master
  elsif payload['action'] == 'synchronize'
    # save current HEAD
    # checkout to branch
    # update branch
    # run pronto to HEAD
  end

  payload.inspect
end
