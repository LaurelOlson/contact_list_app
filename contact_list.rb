#!/usr/bin/env ruby

require_relative 'contact'
require 'pry'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  def initialize
    if ARGV[0]
      puts "Here is a list of available commands:"
      puts "\tnew \t- Create a new contact"
      puts "\tlist \t- List all contacts"
      puts "\tshow \t- Show a contact"
      puts "\tsearch \t- Search contacts"
    end

    command = ARGV[0] || STDIN.gets.chomp

    case command
    when 'new'
      ContactList.create
    when 'list'
      ContactList.list
    when 'show'
      ContactList.show
    when 'search'
      ContactList.search
    end
  end

  def self.create
    puts "Full name of contact:" unless ARGV[1]
    name = ARGV[1] || STDIN.gets.chomp
    puts "Email:" unless ARGV[2]
    email = ARGV[2] || STDIN.gets.chomp
    # puts "Phone number (separate type and number with a space, and multiple numbers with a semicolon ex. mobile: 778-999-7777; home 604-555-6666):" unless ARGV[3]
    # phone_number = ARGV[3] || STDIN.gets.chomp

    # if Contact.search(email).empty?
    Contact.create(name, email)
    # else
      # puts "Contact already exists."
    # end
  end

  def self.list
    formatted_contacts = Contact.all.map { |contact| contact.to_s }
    self.paginate(formatted_contacts, 5)
  end

  def self.show
    puts "what is the ID for the contact you wish to view?" unless ARGV[1]
    id = (ARGV[1] || STDIN.gets.chomp).to_i
    contact = Contact.find(id)
    if contact
      puts "name: #{contact[0]['name']}"
      puts "email: #{contact[0]['email']}"
      # puts "phone number: #{contact[2]}"
    else
      puts "contact not found"
    end
  end

  def self.search
    puts "Search by name, email, or index?" unless ARGV[1]
    key = ARGV[1] || STDIN.gets.chomp 
    puts "Which #{key} are you looking for?" unless ARGV[2]
    value = ARGV[2] || STDIN.get.chomp
    formatted_matches = Contact.search(key, value).map { |match| match.to_s }
    self.paginate(formatted_matches, 5)
  end

  def self.paginate(contacts, per_page)
    total_contacts = contacts.length
    remaining_contacts = contacts.length
    while remaining_contacts > 0
      per_page.times do 
        puts contacts.shift
      end
      remaining_contacts -= per_page
      if remaining_contacts > 0
        print "press enter to show next #{per_page} entries"
        input = STDIN.gets.chomp
      end
    end
    puts "---"
    puts "#{total_contacts} records total"
  end
end

ContactList.new