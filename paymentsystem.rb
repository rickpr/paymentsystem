require 'securerandom'
require 'digest/sha2'
require 'date'
require 'observer'
require './container'

module PaymentSystem
  
  class Password
  
    def initialize password
      @salt = SecureRandom.hex
      @password = Digest::SHA512.hexdigest(@salt + password)
    end
  
    def change old_password, new_password
      initialize new_password if check old_password
    end
  
    def check password
      @password == Digest::SHA512.hexdigest(@salt + password)
    end
  
  end

  class User

    include Container
  
    attr_reader :name, :password

  
    def initialize name, password
      @name = name
      @password = Password.new password
      unique :name
      super()
    end

    def update project, amount
      puts "#{project} is #{-amount} over budget!"
    end


    class << self

      attr_reader :types

      def level
        @level || 0
      end

      private

      def inherited subclass
        subclass.instance_variable_set :@all, []
        @types ||= []
        self.types << subclass
      end

    end
  
  end

  class Employee < User
  
    attr_accessor :wage
  
    def initialize name, password, wage
      @wage       = wage.to_f
      super name, password
    end
  
    def time_cards
      TimeCard.all.select { |timecard| timecard.employee == self }
    end

    def pay
      pay! time_cards.select { |card| card.date <= last_pay_day }
    end
  
    def fire!
      pay!
      delete
    end

    def self.pay_all
      all.each { |employee| employee.pay }
    end
  
  end
  
  class TimeCard

    include Container
  
    attr_reader :employee, :project, :hours, :date
  
    def initialize employee, project, hours, date = Date.today
      @employee = employee
      @project  = project
      @hours    = hours.to_f
      @date     = date
      super()
    end
  
  end
  
  class SalariedEmployee < Employee

    def pay! cards = time_cards
      total_hours = cards.map(&:hours).reduce :+
      cards.each do |card|
        card.project.reduce_funds wage * card.hours / total_hours
        card.delete
      end
    end

    def last_pay_day
      PaymentSystem.configuration.salary_pay_day
    end
  
  end
  
  class HourlyEmployee < Employee

    def pay! cards = time_cards
      cards.each do |card|
        card.project.reduce_funds wage * card.hours
        card.delete
      end
    end

    def last_pay_day
      PaymentSystem.configuration.hourly_pay_day
    end

  end
  
  class Project
  
    include Observable, Container

    attr_reader :name
  
    def initialize name, funds, manager
      @name      = name
      @funds     = funds.to_f
      add_observer manager
      super()
    end
    
    def reduce_funds amount
      @funds -= amount
      notify_observers(@name, @funds) if @funds < 0
    end
  
  end

  class ProjectManager < User
    @level = 1
  end
  
  class PayrollClerk < User 
    @level = 2
  end
 
end
