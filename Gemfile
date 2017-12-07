ruby "~> 2.3.0"

source 'https://rubygems.org/'

group :dev, :test do
  gem 'rake', '~>12.2.0'
end

group :test do
  gem 'bundler', '~>1.16.0'
  gem 'colorize', '~>0.8.0'
  gem 'kitchen-terraform', '~>3.0.0'
  gem 'rspec', '~>3.7.0'
  gem 'test-kitchen', '~>1.16.0'
  git 'https://github.com/Azure/terramodtest.git' do
    gem 'terramodtest', :tag => 'v0.1.0'
  end
end
