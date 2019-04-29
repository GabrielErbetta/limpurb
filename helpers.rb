# frozen_string_literal: true

def json_params
  JSON.parse(request.body.read)
rescue JSON::ParserError
  halt 500, { message: 'Invalid JSON' }.to_json
end

def load_git_repo(r_owner, r_name)
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

def pronto_formatters
  formatter = Pronto::Formatter::GithubPullRequestReviewFormatter.new
  status_formatter = Pronto::Formatter::GithubStatusFormatter.new
  [formatter, status_formatter]
end
