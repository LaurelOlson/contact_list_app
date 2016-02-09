
require_relative 'contact'

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
      puts "Contact name:"
      name = gets.chomp
      puts "Contact email:"
      email = gets.chomp
      Contact.new.create(name, email)
    when 'list'
      Contact.all
    when 'show'
      Contact.find(id)
    when 'search'
      Contact.search(term)
    end
  end
end

ContactList.new