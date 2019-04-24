# frozen_string_literal: true

def json_params
  JSON.parse(request.body.read)
rescue JSON::ParserError
  halt 500, { message: 'Invalid JSON' }.to_json
end

def setup_git
  Git.clone('git@github.com:pastar-br/pastar-web-server.git',
            'pastar-web-server',
            path: '/git/pastar-web-server')
end
