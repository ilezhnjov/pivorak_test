require 'bcrypt'
require 'io/console'
require 'yaml'
require 'rubygems'
require 'highline/import'

def atm

      # Load data from config file
      config = YAML.load_file(ARGV.first || 'config-01.yml')

      # Get info about accessible cash
      atm_cash = config['banknotes']
      amount_cash = 0
      atm_cash.each do |key, value|
        if value != 0
          amount_cash = amount_cash + (key*value)
        end
      end

      # Get info about customer
      customers = config['accounts']

      # Registration procedure in ATM
      pin_code = ''

    while true
      begin
        cust_name = ask("Enter your username:  ") { |q| q.echo = true }
        # Customer name
        u_name = cust_name.to_i
        # Get digest of customer password
        pin_digest = customers[u_name]['password']
        cust_pw = BCrypt::Password.new(pin_digest)
        pin_code = ask("Enter your password:  ") { |q| q.echo = "*" }
        break if cust_pw == pin_code
        puts "ERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
      rescue NoMethodError
        puts "ERROR: LOGIN UNDEFINED, PLEASE INPUT AGAIN"
      end
    end

      # Define current user of ATM
      current_user = customers[u_name]['name']
      bal = customers[u_name]['balance']
   puts "*******************"
   puts "Welcome, #{current_user}!"
   puts "*******************"

  loop do

    puts "1. Display Balance", "2. Withdraw", "3. Log Out"

    input = ask("Your choice:  ") { |q| q.echo = true }

    case input

      when "1"
        # Displaying Balance
        puts "Your Current Balance is ₴#{bal}"

      when "2"
        # withdrawing money
        withdraw_input = 0
        withdraw_input = ask("Enter Amount You Wish to Withdraw:  ") { |q| q.echo = true }

        while withdraw_input.to_i > bal.to_i * 2
          withdraw_input = ask("ERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT: ") { |q| q.echo = true }
        end

        while withdraw_input.to_i > amount_cash do
          withdraw_input = ask("ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴#{amount_cash}. PLEASE ENTER A DIFFERENT AMOUNT: ") { |q| q.echo = true }
        end

        while withdraw_input.to_i <= bal.to_i and withdraw_input.to_i <= amount_cash and withdraw_input.to_s[-1] != '0'
          withdraw_input = ask("ERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. PLEASE ENTER A DIFFERENT: ") { |q| q.echo = true }
        end

        while bal.to_i < withdraw_input.to_i and withdraw_input.to_i  < amount_cash
          withdraw_input = ask("ERROR: YOU HAVE NO ENOUGH ASSETS ON ACCOUNT: ")  { |q| q.echo = true }
        end

        if withdraw_input.to_i <= bal.to_i and withdraw_input.to_i <= amount_cash and withdraw_input.to_s[-1] == '0'
          withdraw_input.to_s[-1] == 0
          bal = bal.to_i - withdraw_input.to_i
          puts "Your New Balance is: ₴#{bal}"
          config['accounts'][u_name]['balance'] = bal.to_s
          File.write('config.yml', config.to_yaml)
        end

      when "3"
        puts "*******************i**********************************"
        puts "#{current_user}, Thank You For Using Our ATM. Good-Bye!"
        puts "*******************i**********************************"
        atm
        return
      else
        puts "Invalid option: #{input}"
      end
    end
  rescue SystemExit, Interrupt
    puts "ATM Interrupted!"
end
atm
