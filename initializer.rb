#!/usr/bin/env ruby
require 'io/console'
require './routine'

PaymentSystem.configure do |config|
  config.hourly_day    = "Friday"
  config.salary_day    = 1
  config.payroll_clerk   "Ricardo", "password"
end

PaymentSystem.run
