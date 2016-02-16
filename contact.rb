require 'pg'

class Contact

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
    results = self.connection.exec("SELECT * FROM contacts;")
    process_results(results)
  end

  # Creates a new contact and saves the contact to the database, returning the new contact.
  def self.create(name, email)
    contact = Contact.new(name, email)
    contact.save
    contact
  end

  # Returns the contact with the specified id. If no contact has the id, returns nil.
  def self.find(id)
    result = CONN.exec_params("SELECT * FROM contacts WHERE id = $1::int LIMIT 1;", [id])
    Contact.new(result[0]["name"], result[0]["email"], result[0]["id"])
  end

  # Returns an array of Contacts who match the given key and value.
  def self.search(key, value)
    results = CONN.exec_params("SELECT * FROM contacts WHERE #{key} = $1;", [value])
    process_results(results)
  end

  def self.process_results(results)
    contacts = []
    results.each do |contact|
      contacts << Contact.new(contact["name"], contact["email"], contact["id"])
    end
    contacts
  end

  # Checks if the contact is persisted (i.e. if it exists in the database)
  def persisted?
    !id.nil?
  end

  # Either updates an exisiting contact or saves a new contact.
  def save
    if persisted? # save updated info
      CONN.exec_params("UPDATE contacts SET name = $1, email = $2 WHERE id = $3::int;", [@name, @email, @id])
    else #save new info
      result = CONN.exec_params("INSERT INTO contacts(name, email) VALUES ($1, $2) RETURNING id;", [@name, @email])
      @id = result[0]["id"]
    end
  end

  def destroy
    CONN.exec_params("DELETE FROM contacts WHERE id = $1::int;", [@id])
  end

end