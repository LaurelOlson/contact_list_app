require 'pg'

# Represents a person in an address book.
class Contact

  # CSV_FNAME = 'csv.txt'
  CONN = PG::Connection.new(host: 'localhost', port: 5432, dbname: 'contact_list', user: 'development', password: 'development')

  attr_accessor :name, :email, :phone_number
  attr_reader :id

  def initialize(name, email, id=nil)
    @name = name
    @email = email
    @id = id
    # @phone_number = phone_number
  end
  
  def self.connection
    CONN
  end

  # Creates a string representation of Contact instances in contacts
  def to_s
    "#{@id}: #{@name}\temail: #{@email}"
  end

  # Returns an Array of Contacts loaded from the database.
  def self.all
    all_contacts = []
    results = self.connection.exec("SELECT * FROM contacts;")
    results.each do |contact|
      all_contacts << Contact.new(contact['name'], contact['email'], contact ['id'])
    end
    all_contacts
  end

  # Creates a new contact, returning the new contact.
  def self.create(name, email)
    contact = Contact.new(name, email)
    contact.save(name, email)
  end

  # Adds new contact to the database
  def self.add_to_db(name, email, phone_number)
    CSV.open(CSV_FNAME, 'ab') do |csv|
      csv << ["#{name}", "#{email}", "#{phone_number}"]
    end
  end

  # Returns the contact with the specified id. If no contact has the id, returns nil.
  def self.find(id)
    CONN.exec_params("SELECT * FROM contacts WHERE id = $1::int LIMIT 1;", [id])
    # CSV.read(CSV_FNAME)[(id-1)]
  end

  # Returns an array of Contacts who match the given term.
  def self.search(key, value)
    # matches = Contact.all.find { |contact| contact.name =~ /#{term}/ }
    results = CONN.exec_params("SELECT * FROM contacts WHERE #{key} = $1;", [value])

    matches = []
    results.each do |contact|
      matches << Contact.new(contact["name"], contact["email"], contact["id"])
    end

    matches

    # matches = []
    # id = 1
    # CSV.foreach(CSV_FNAME) do |row|
    #   name = row[0]
    #   email = row[1]
    #   phone_number = row[2]
    #   matches << Contact.new(name, email, phone_number, id) unless row.grep(/#{term}/).empty?
    #   id += 1
    # end
    # matches
  end

  def persisted?
    !id.nil?
  end

  def save(name, email)
    if persisted?
      # save updated info
    else
      #save new info
      result = CONN.exec_params("INSERT INTO contacts(name, email) VALUES ($1, $2) RETURNING id;", [name, email])
      result[0]["id"]
    end
  end

end