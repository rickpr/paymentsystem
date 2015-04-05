require './config'

module PaymentSystem

  class << self

    def run
      loop do
        begin
          current_user = login until current_user
          puts "Logged in."
          options_for current_user
        rescue StandardError => error
          puts "Woops. Something went wrong"
          puts error
          print "Continue? (yes/no): "
          gets.chomp == "yes" ? next : break
        end
      end
    end

    private

    def login
      puts "Welcome to PaymentSystem. Please log in."
      role = login_type
      check_credentials role
    end

    def login_type user_type = User
      if user_type.types
        puts "Select a role:"
        type = optionize user_type.types
        login_type type
      else
        user_type
      end
    end

    def check_credentials role
      print "Username: "
      username = gets.chomp
      print "Password: "
      password = STDIN.noecho(&:gets).chomp
      puts
      logged_in = role.all.find { |user| user.name == username }
      logged_in if logged_in && logged_in.password.check(password)
    end

    def options_for user 
      all_options = { "Time Cards"    => { level: 0, method: :time_cards} ,
                      "Projects"      => { level: 1, method: :projects },
                      "Add Users"     => { level: 2, method: :users },
                      "Pay All"       => { level: 2, method: :pay_all },
                      "Fire Employee" => { level: 2, method: :fire } }
      user_options = []
      all_options.each do |option, value|
        next unless value[:level] == user.class.level
        user_options << option
      end
      puts "Select an option:"
      selection = optionize user_options
      send all_options[selection][:method], user
    end

    def time_cards user
      puts "You have #{user.time_cards.length} time cards."
      print "Enter year of time card: "
      year = gets.chomp
      print "Enter month of time card: "
      month = gets.chomp
      print "Enter day of time card: "
      day = gets.chomp
      print "Select a project: "
      project = optionize Project.all, Project.all.map(&:name)
      print "Enter hours worked: "
      hours = gets.chomp
      TimeCard.new user, project, hours, Date.parse([year,month,day].join "-")
    end

    def projects user
      print "Enter project name: "
      name = gets.chomp
      print "Enter project starting funds: "
      funds = gets.chomp
      Project.new name, funds, user
    end

    def users user
      user_type = login_type
      print "Choose a username: "
      username = gets.chomp
      password_confirmed = false
      until password_confirmed
        puts "Password not set."
        print "Choose a password: "
        password = STDIN.noecho(&:gets).chomp
        puts
        print "Confirm password: "
        password_confirmed = password == STDIN.noecho(&:gets).chomp
        puts
      end
      if user_type.superclass == Employee
        print "Enter wage amount: "
        wage = gets.chomp
        user_type.new username, password, wage
      else
        user_type.new username, password
      end
    end

    def pay_all user
      Employee.types.each { |subclass| subclass.pay_all }
    end

    def fire user
      employees = login_type.all
      puts "Select an employee to fire: "
      employee = optionize employees
      employee.fire!
    end

    def optionize items, display = items
      display.each.with_index(1) { |item,index| puts "#{index}: #{item}"}
      print ">"
      items[gets.chomp.to_i - 1]
    end

  end

end
