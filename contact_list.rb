#!/usr/bin/env ruby

require_relative 'phone_number'
require_relative 'contact'
require 'pry'

# Interfaces between a user and their contact list. Reads from and writes to standard I/O.
class ContactList

  def initialize
    unless ARGV[0]
      puts "Here is a list of available commands:"
      puts "\tnew \t- Create a new contact"
      puts "\tlist \t- List all contacts"
      puts "\tshow \t- Show a contact"
      puts "\tsearch \t- Search contacts"
      puts "\tupdate \t- Update an existing contact"
      puts "\tremove \t- Remove a contact"
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
    when 'update'
      ContactList.update
    when 'remove'
      ContactList.destroy
    end
  end

  def self.create
    puts "Full name of contact:" unless ARGV[1]
    name = ARGV[1] || STDIN.gets.chomp
    puts "Email:" unless ARGV[2]
    email = ARGV[2] || STDIN.gets.chomp
    puts "Phone number (include type and number separated by a space, and multiple numbers separated by a semi-colon ex. mobile 7789997777; home 6045223456)" unless ARGV[3]
    phone_numbers = (ARGV[3] || STDIN.gets.chomp).split('; ')
    phone_number = Hash.new
    phone_numbers.each do |entry|
      type = entry.split(' ')[0]
      number = entry.split(' ')[1]
      phone_number[type.to_sym] = number
    end

    if Contact.search('email', email).empty?
      Contact.create(name, email, phone_number)
    else
      puts "Contact already exists."
    end
  end

  def self.list
    self.paginate(format_contacts(Contact.all) , 5)
  end

  def self.format_contacts(contacts)
    formatted_contacts = []
    contacts.each do |contact| 
      contact.each_value do |value|
        formatted_contacts << format_contact(value)
      end
    end
    formatted_contacts
  end

  def self.format_contact(contact)
    formatted_contact = ""
    if contact.phone_number
      numbers = []
      contact.phone_number.each { |key, value| numbers << "#{key}: #{value}"}
      formatted_contact += "#{contact.id}:\t#{contact.name}\temail: #{contact.email}\tphone number: "
      numbers.each do |phone_number|
        formatted_contact += "#{phone_number}\t"
      end
    else
      formatted_contact += "#{contact.id}:\t#{contact.name}\temail: #{contact.email}"
    end
    formatted_contact
  end

  def self.show
    puts "what is the ID for the contact you wish to view?" unless ARGV[1]
    id = (ARGV[1] || STDIN.gets.chomp).to_i
    contact = Contact.find(id) # this returns the contact
    if contact
      puts "name: #{contact.name}"
      puts "email: #{contact.email}"
      puts "phone number: #{contact.phone_number}" if contact.phone_number
    else
      puts "contact not found"
    end
  end

  def self.search
    puts "Search by name, email, or id?" unless ARGV[1]
    key = ARGV[1] || STDIN.gets.chomp 
    if ['name', 'email', 'id'].include?(key)
      puts "Which #{key} are you looking for?" unless ARGV[2]
      value = ARGV[2] || STDIN.gets.chomp
      formatted_matches = []
      self.paginate(format_contacts(Contact.search(key, value)), 5)
    else
      puts "#{key} is not a valid search parameter"
    end
  end

  def self.update
    puts "What is the id of the contact you wish to update?" unless ARGV[1]
    id = ARGV[1] || STDIN.gets.chomp
    contact = Contact.find(id)
    puts "What is the new name for contact #{id}?" unless ARGV[2]
    contact.name = ARGV[2] || STDIN.gets.chomp
    puts "What is the new email for contact #{id}" unless ARGV[3]
    contact.email = ARGV[3] || STDIN.gets.chomp
    contact.save
  end

  def self.destroy
    puts "What is the id of the contact you wish to delete?" unless ARGV[1]
    id = ARGV[1] || STDIN.gets.chomp
    contact = Contact.find(id)
    contact.destroy
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