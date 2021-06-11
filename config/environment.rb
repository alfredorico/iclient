# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
  :authentication => :plain,
  :address => "smtp.company.org",
  :port => 587,
  :domain => "company.com",
  :user_name => "postmaster@company.com",
  :password => "xxxxxxxxxxxxxxxxx"
}