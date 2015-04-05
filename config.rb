require './paymentsystem'

module PaymentSystem

   class Configuration

    attr_writer :hourly_day, :salary_day

    def hourly_pay_day
      pay_day     = Date.today
      day_of_week = Date.parse(@hourly_day).wday
      until pay_day.wday == day_of_week
        pay_day -= 1
      end
      pay_day
    end

    def salary_pay_day
      @salary_day > 0 ? month = Date.today : month = Date.today << 1
      Date.new(month.year, month.month, @salary_day)
    end

    def payroll_clerk name, password
      PayrollClerk.new name, password
    end

  end

  class << self

    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield configuration if block_given?
    end

  end
 
end
