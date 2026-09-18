# frozen_string_literal: true

# Interactively creates an admin user from console input (see users:create_admin).
# Passwords are read without echo; the process exits with status 1 when the input is rejected.
class AdminUserCreator
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
  end

  def call
    announce
    report_created(User.create!(**admin_attributes))
  rescue ActiveRecord::RecordInvalid => error
    report_invalid(error.record)
  end

  private

  def announce
    @output.puts "Creating new admin user..."
    blank_line
  end

  def confirmed_password
    password = ask_hidden("Password: ")
    return password if password == ask_hidden("Confirm password: ")

    @output.puts "Error: Passwords don't match"
    exit 1
  end

  def admin_attributes
    email = ask("Email address: ")
    name = ask("Name: ")
    password = confirmed_password

    {
      email_address: email,
      password: password,
      password_confirmation: password,
      name: name,
      role: :admin,
      status: :active
    }
  end

  def report_created(user)
    blank_line
    @output.puts "Successfully created admin user: #{user.name}"
    @output.puts "Email: #{user.email_address}"
  end

  def report_invalid(record)
    blank_line
    @output.puts "Failed to create user:"
    record.errors.full_messages.each { |message| @output.puts "  - #{message}" }
    exit 1
  end

  def ask(prompt)
    @output.print prompt
    @input.gets.chomp
  end

  def ask_hidden(prompt)
    @output.print prompt
    answer = @input.noecho(&:gets).chomp
    blank_line
    answer
  end

  def blank_line
    @output.puts ""
  end
end
