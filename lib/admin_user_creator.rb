# frozen_string_literal: true

# Interactively creates an admin user from console input (see users:create_admin).
# Passwords are read without echo; the process exits with status 1 when the input is rejected.
class AdminUserCreator
  def initialize(input: $stdin, output: $stdout)
    @input = input
    @output = output
  end

  def call
    @output.puts "Creating new admin user..."
    @output.puts ""

    email = ask("Email address: ")
    name = ask("Name: ")
    password = ask_hidden("Password: ")
    password_confirmation = ask_hidden("Confirm password: ")

    unless password == password_confirmation
      @output.puts "Error: Passwords don't match"
      exit 1
    end

    user = User.create!(
      email_address: email,
      password: password,
      password_confirmation: password,
      name: name,
      role: :admin,
      status: :active
    )

    @output.puts ""
    @output.puts "Successfully created admin user: #{user.name}"
    @output.puts "Email: #{user.email_address}"
  rescue ActiveRecord::RecordInvalid => e
    @output.puts ""
    @output.puts "Failed to create user:"
    e.record.errors.full_messages.each { |error| @output.puts "  - #{error}" }
    exit 1
  end

  private

  def ask(prompt)
    @output.print prompt
    @input.gets.chomp
  end

  def ask_hidden(prompt)
    @output.print prompt
    answer = @input.noecho(&:gets).chomp
    @output.puts ""
    answer
  end
end
