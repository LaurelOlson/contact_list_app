
require_relative 'contact'
require 'pry'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  # TODO: Implement user interaction. This should be the only file where you use `puts` and `gets`.

  def initialize

    puts "Here is a list of available commands:"
    puts "\tnew \t- Create a new contact"
    puts "\tlist \t- List all contacts"
    puts "\tshow \t- Show a contact"
    puts "\tsearch \t- Search contacts"
    @command = gets.chomp

    case @command
    when 'new'
      puts "Full name of contact name:"
      name = gets.chomp
      puts "Email:"
      email = gets.chomp
      Contact.create(name, email)
    when 'list'
      Contact.all
    when 'show'
      Contact.find(id)
    when 'search'
      Contact.search(term)
    end
  end
end
binding.pry
ContactList.new