
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
      if Contact.search(email).empty?
        Contact.create(name, email)
      else
        puts "Contact already exists."
      end
    when 'list'
      n = 0
      Contact.all.each do |entry|
        n += 1
        name = entry.split(', ')[0]
        email = entry.split(', ')[1].chomp
        puts "#{name} (#{email})"
      end
      puts "---"
      puts "#{n} records total"
    when 'show'
      puts "what is the ID for the contact you wish to view?"
      id = gets.chomp.to_i
      contact = Contact.find(id)
      if contact
        contact = contact.chomp.split(', ')
        puts "name: #{contact[0]}"
        puts "email: #{contact[1]}"
      else
        puts "contact not found"
      end
    when 'search'
      puts "Enter a search term (ex. name)"
      term = gets.chomp
      matches = Contact.search(term)
      n = 0
      matches.each do |contact|
        n += 1
        id = contact.split(', ')[0]
        name = contact.split(', ')[1]
        email = contact.split(', ')[2]
        puts "#{id}: #{name} #{email}"
      end
      puts "---"
      puts "#{n} record total"
    end
  end
end
binding.pry
ContactList.new