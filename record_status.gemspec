Gem::Specification.new do |s|
  s.name        = 'record_status'
  s.version     = '0.0.0'
  s.summary     = 'Support for standard record statuses.'
  s.description = 'Wrapper for common record status fields, scopes, etc.'
  s.authors     = ['Ralph Churchill']
  s.email       = 'ralph.churchill@vitals.com'
  s.homepage    = 'https://github.com/organizations/mdx-dev'
  s.files       = [
    'Gemfile',
    'README.md',
    'VERSION',
    'lib/record_status.rb',
    'lib/record_status/record_status.rb',
  ]
  s.test_files  = [
    'spec/record_status_spec.rb',
    'spec/spec_helper.rb',
  ]
  s.add_dependency('rails', ['>= 3.2.0'])
end

