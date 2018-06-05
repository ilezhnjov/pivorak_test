require 'bcrypt'
require 'io/console'
require 'yaml'
require 'rubygems'
require 'highline/import'

def atm

      # Load data from config file
      config = YAML.load_file(ARGV.first || 'config-02.yml')

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
        cust_name = ask("Enter your username:  ")
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
      # Get current user balance
      bal = customers[u_name]['balance']
      # Greeting current user
      puts "*******************"
      puts "Welcome, #{current_user}!"
      puts "*******************"

if cust_name == '0001' and customers[u_name]['status'] == 'unlock'

  loop do
    # Show admin menu
    puts "1. Display bills", "2. Display accounts", "3. Change bills", 
         "4. Change balance", "5. Reset password", "6. Log Out"

    input = ask("Your choice:  ")

    case input

    # show bills set
    when "1"
      puts config['banknotes'].to_yaml

    # show accounts
    when "2"
      puts config['accounts'].to_yaml

    # change bills set
    when "3"
      init_bills_val = {}
      [500, 200, 100, 50, 20, 10, 5, 2, 1].each do |key|
        val = ask("New value for bills #{key}:  ")
        init_bills_val[key] = val.to_i
      end
      init_bills_val.each do |key, val|
        atm_cash[key] = val
      end
      File.write('config-02.yml', config.to_yaml)
      puts config['banknotes'].to_yaml

    # change account balance
    when "4"
      while true
        acc_number = ask("Account number:  ")
        if customers.include? acc_number.to_i
          init_bal = ask("New balance value:  ")
          num = acc_number.to_i
          config['accounts'][num]['balance'] = init_bal
          File.write('config-02.yml', config.to_yaml)
          puts config['accounts'][num].to_yaml
          break
        else
          puts "ERROR: UNDEFINED ACCOUNT NUMBER"
        end
      end

    # change account password
    when "5"
      while true
      acc_number = ask("Account number:  ")
      if customers.include? acc_number.to_i
        new_passwd = ask("Enter new password:  ") { |q| q.echo = "*" }
        newPW = BCrypt::Password.create(new_passwd)
        retype_pwd = ask("Retype new password:  ") { |q| q.echo = "*" }
        if newPW == retype_pwd
          num = acc_number.to_i
          config['accounts'][num]['password'] = newPW
          File.write('config-02.yml', config.to_yaml)
          puts "Password changed."
          break
        else
          puts "ERROR: ACCOUNT NUMBER AND PASSWORD DON'T MATCH"
        end
      else
        puts "ERROR: UNDEFINED ACCOUNT NUMBER"
      end
      end


    # exit from admin menu
    when "6"
      puts "*****************************************************"
      puts "#{current_user}, Thank You For Using Our ATM. Good-Bye!"
      puts "*****************************************************"
      atm
      return
    else
      puts "WARNING! Invalid option: #{input}"
    end

  end

else

  loop do
    # Show menu  
    puts "1. Display Balance", "2. Withdraw", "3. Log Out"

    input = ask("Your choice:  ")

    case input

      when "1"
        # Displaying Balance
        puts "Your Current Balance is ₴ #{bal}"

      when "2"
        # withdrawing money
        withdraw_input = 0
        withdraw_input = ask("Enter Amount You Wish to Withdraw:  ")

        while withdraw_input.to_i > bal.to_i * 2
          withdraw_input = ask("ERROR: INSUFFICIENT FUNDS!! PLEASE ENTER A DIFFERENT AMOUNT: ")
        end

        while withdraw_input.to_i > amount_cash do
          withdraw_input = ask("ERROR: THE MAXIMUM AMOUNT AVAILABLE IN THIS ATM IS ₴ #{amount_cash}. 
                               PLEASE ENTER A DIFFERENT AMOUNT: ") 
        end

        while bal.to_i < withdraw_input.to_i and withdraw_input.to_i  < amount_cash
          withdraw_input = ask("ERROR: YOU HAVE NO ENOUGH ASSETS ON ACCOUNT: ")  
        end

        while withdraw_input.to_i <= bal.to_i and withdraw_input.to_i <= amount_cash
          x = withdraw_input.to_i
          sum = 0
          new_bills_val = {}
          atm_cash.each do |key, val|
            if val != 0 and sum < x and sum != x
              if x <= (key * val) and k = ( x - sum ) / key and k != 0 and (x - sum) > (key * k) or 
                  x > (key * val) and (key * val) >= (x - sum) and k = ( x - sum ) / key and k != 0
                sum = sum + (key * k)
                bill_counter = val - k
                new_bills_val[key] = bill_counter
              elsif (x - sum) > (key * val)
                sum = sum + (key * val)
                bill_counter_zero = key
                new_bills_val[key] = 0
              end
            end
          end
          break if sum == x
          withdraw_input = ask("ERROR: THE AMOUNT YOU REQUESTED CANNOT BE COMPOSED FROM BILLS AVAILABLE IN THIS ATM. 
                               PLEASE ENTER A DIFFERENT: ") 
        end
        # update bills and balance info
        new_bills_val.each do |key, val|
          atm_cash[key] = val
        end
        bal = bal.to_i - sum
        config['accounts'][u_name]['balance'] = bal.to_s
        File.write('config-02.yml', config.to_yaml)
        puts "Your New Balance is: ₴ #{bal}"

      # current user log out
      when "3"
        puts "******************************************************"
        puts "#{current_user}, Thank You For Using Our ATM. Good-Bye!"
        puts "******************************************************"
        atm
        return
      else
        puts "WARNING! Invalid option: #{input}"
      end
    end
  end
  rescue SystemExit, Interrupt
    puts " ATM was interrupted!"
end
atm
