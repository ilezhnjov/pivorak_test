require "base64"
require 'io/console'
require 'yaml'
require 'rubygems'
require 'highline/import'

if ARGV.length != 1
    puts "We need exactly one parameter. The name of a file."
    exit;
end

def menu
    # Login input
    cust_name = ask("Enter your username:  ") { |q| q.echo = true }
    pin_code = ask("Enter your password:  ") { |q| q.echo = "*" }

    # Load data from YAML
    config = YAML.load_file(ARGV[0])
    atm_cash = config['banknotes']
    amount_cash = 0
    atm_cash.each do |key, value|
      if value != 0
        amount_cash = amount_cash + (key*value)
      end
    end

    customers = config['accounts']
    u_name = cust_name.to_i
    bal = customers[u_name]['balance']

    # Validation of login/password
    cust_pw = Base64.encode64(pin_code)
    pin_digest = customers[u_name]['password']

    if current_user = customers[u_name]['name'] and cust_pw[(0..-2)] == pin_digest
      puts "Welcome, #{current_user}!"
      # If validation success run Menu

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

              if withdraw_input.to_i <= bal.to_i and withdraw_input.to_i <= amount_cash and withdraw_input.to_s[-1] == '0'
                withdraw_input.to_s[-1] == 0
                bal = bal.to_i - withdraw_input.to_i
                puts "Your New Balance is: #{bal}"
                config['accounts'][u_name]['balance'] = bal.to_s
                File.write('config.yml', config.to_yaml)
              end

           when "3"
             puts "#{current_user}, Thank You For Using Our ATM. Good-Bye!"
             return
           else
            puts "Invalid option: #{input}"
          end
       end
    end
end
menu

