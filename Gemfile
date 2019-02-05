#ruby "~> 2.5.1"

source "https://rubygems.org/" do
  gem(
    "kitchen-terraform",
    "~> 4.0"
  )
end

group :test do
  git 'https://github.com/Azure/terramodtest.git' do
    gem 'terramodtest', :tag => 'v0.2.0'
  end
end
