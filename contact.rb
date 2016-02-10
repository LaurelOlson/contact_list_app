require 'csv'

# Represents a person in an address book.
class Contact

  CSV_FNAME = 'csv.txt'
  attr_accessor :name, :email, :phone_number, :id

  def initialize(name, email, phone_number, id=nil)
    @name = name
    @email = email
    @phone_number = phone_number
    @id = id
  end

  # Creates a string representation of Contact instances in contacts
  def to_s
    "#{@id}: #{@name}\temail: #{@email}\tphone number(s): #{@phone_number}"
  end

  # Provides functionality for managing a list of Contacts in a database.
  class << self

    # Returns an Array of Contacts loaded from the database.
    def all
      contacts = []
      id = 1
      CSV.foreach(CSV_FNAME) do |row|
        name = row[0]
        email = row[1]
        phone_number = row[2]
        contacts << Contact.new(name, email, phone_number, id)
        id += 1
      end
      contacts
    end

    # Creates a new contact, returning the new contact.
    def create(name, email, phone_number)
      new_contact = Contact.new(name, email, phone_number)

    end

    # Adds new contact to the database
    def add_to_db(name, email, phone_number)
      CSV.open(CSV_FNAME, 'ab') do |csv|
        csv << ["#{name}", "#{email}", "#{phone_number}"]
      end
    end

    # Returns the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      CSV.read(CSV_FNAME)[(id-1)]
    end

    # Returns an array of Contacts who match the given term.
    def search(term)
      matches = []
      id = 1
      CSV.foreach(CSV_FNAME) do |row|
        name = row[0]
        email = row[1]
        phone_number = row[2]
        matches << Contact.new(name, email, phone_number, id) unless row.grep(/#{term}/).empty?
        id += 1
      end
      matches
    end

  end

end