require 'csv'

# Represents a person in an address book.
class Contact

  attr_accessor :name, :email

  def initialize(name, email)
    @name = name
    @email = email
    
    # TODO: Assign parameter values to instance variables.
  end

  # Provides functionality for managing a list of Contacts in a database.
  class << self

    # Returns an Array of Contacts loaded from the database.
    def all
      contacts = []
      File.open('csv.txt', 'r').readlines.each do |line|
        contacts << line
      end
      contacts
    end

    # Creates a new contact, adding it to the database, returning the new contact.
    def create(name, email)
      new_contact = Contact.new(name, email)
      File.open('csv.txt', 'a') do |file|
        file.write "#{name}, #{email}\n"
      end
      new_contact
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      entry = File.open('csv.txt', 'r').readlines[id]
    end

    # Returns an array of contacts who match the given term.
    def search(term)
      matches = []
      n = 0
      File.open('csv.txt', 'r').readlines.each do |line|
        n += 1
        matches << "#{n}, #{line}" if line[/#{term}/]
      end
      matches
    end

  end

end