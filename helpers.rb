# frozen_string_literal: true

def json_params
  JSON.parse(request.body.read)
rescue JSON::ParserError
  halt 500, { message: 'Invalid JSON' }.to_json
end

def pronto_formatters
  formatter = Pronto::Formatter::GithubPullRequestReviewFormatter.new
  status_formatter = Pronto::Formatter::GithubStatusFormatter.new
  [formatter, status_formatter]
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

  repo.branch("pr-#{pr_number}-base").delete rescue nil
  repo.branch("pr-#{pr_number}").delete rescue nil

  repo.fetch('origin', ref: "#{pr_base}:pr-#{pr_number}-base")
  repo.fetch('origin', ref: "pull/#{pr_number}/head:pr-#{pr_number}")
  repo.branch("pr-#{pr_number}").checkout

  ENV['PRONTO_PULL_REQUEST_ID'] = pr_number.to_s
  Pronto.run(pr_base, "repos/#{repo_owner}/#{repo_name}", pronto_formatters)
end

def process_synchronize_pr(repo_owner, repo_name, pr_number, pr_base)
  # TODO

  # save current HEAD
  # checkout to branch
  # update branch
  # run pronto to HEAD
end
