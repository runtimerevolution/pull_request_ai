# frozen_string_literal: true

require_relative 'lib/pull_request_ai/version'

Gem::Specification.new do |spec|
  spec.name        = 'pull_request_ai'
  spec.version     = PullRequestAi::VERSION
  spec.authors     = ['Runtime Revolution']
  spec.email       = ['info@runtime-revolution.com']
  spec.homepage    = 'http://www.runtime-revolution.com/'
  spec.summary     = 'Rails Engine that provides pull requests descriptions generated by ChatGPT.'
  spec.description = 'Rails Engine that provides pull requests descriptions generated by ChatGPT.'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri']    = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/runtimerevolution/pull_request_ai'
  spec.metadata['changelog_uri']   = 'https://github.com/runtimerevolution/pull_request_ai'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  end

  spec.add_dependency('dry-monads')
  spec.add_dependency('git_clone_url')
  spec.add_dependency('httparty')
  spec.add_dependency('rack-attack')
  spec.add_dependency('rails', '>= 6.1.4')
end
