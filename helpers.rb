# frozen_string_literal: true

def json_params
  JSON.parse(request.body.read)
rescue JSON::ParserError
  halt 500, { message: 'Invalid JSON' }.to_json
end

def pronto_formatters
  formatters = []

  # formatters << Pronto::Formatter::GithubFormatter.new
  # formatters << Pronto::Formatter::GithubPullRequestFormatter.new
  formatters << Pronto::Formatter::GithubPullRequestReviewFormatter.new
  formatters << Pronto::Formatter::GithubStatusFormatter.new

  formatters
end

def load_git_repo(r_owner, r_name)
  File.new("#{settings.root}/log/#{r_owner}_#{r_name}.log", 'a+')
  log = Logger.new("#{settings.root}/log/#{r_owner}_#{r_name}.log")

  begin
    repo = Git.open("#{settings.root}/repos/#{r_owner}/#{r_name}", log: log)
  rescue ArgumentError
    repo = Git.clone("git@github.com:#{r_owner}/#{r_name}.git",
                     r_name,
                     path: "#{settings.root}/repos/#{r_owner}",
                     log: log)
  end
  repo
end

def process_opened_pr(repo_owner, repo_name, pr_number, pr_base)
  repo = load_git_repo repo_owner, repo_name
  base = "pr-#{pr_number}-base"
  head = "pr-#{pr_number}"

  # Delets old branches (rescue avoids errors when branches don't exist already)
  repo.branch(base).delete rescue nil
  repo.branch(head).delete rescue nil

  # Fetches head and base branches and checkouts to head
  repo.fetch('origin', ref: "#{pr_base}:#{base}")
  repo.fetch('origin', ref: "pull/#{pr_number}/head:#{head}")
  repo.branch(head).checkout

  ENV['PRONTO_PULL_REQUEST_ID'] = pr_number.to_s
  Pronto.run(base, "repos/#{repo_owner}/#{repo_name}", pronto_formatters)
end

def process_sync_pr(repo_owner, repo_name, pr_number, pr_base)
  repo = load_git_repo repo_owner, repo_name
  base = "pr-#{pr_number}-base"
  head = "pr-#{pr_number}"

  # Deletes old base branch and runs process_opened_pr if it doesn't exists
  begin
    repo.branch(base).delete
  rescue StandardError
    return process_opened_pr(repo_owner, repo_name, pr_number, pr_base)
  end

  # Makes the current head the new base branch
  repo.branch(head).checkout
  repo.checkout(base, new_branch: true)

  # Delets old head and fetches the head again
  repo.branch(head).delete rescue nil
  repo.fetch('origin', ref: "pull/#{pr_number}/head:#{head}")
  repo.branch(head).checkout

  ENV['PRONTO_PULL_REQUEST_ID'] = pr_number.to_s
  Pronto.run(base, "repos/#{repo_owner}/#{repo_name}", pronto_formatters)
end
