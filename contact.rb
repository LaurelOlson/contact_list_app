require 'pg'

class Contact

  CONN = PG::Connection.new(host: 'localhost', port: 5432, dbname: 'contact_list', user: 'development', password: 'development')

  attr_accessor :name, :email, :phone_number
  attr_reader :id

  # phone_number is a hash with type as key, number as value
  # ex. phone_number = { mobile: 7786665555, home: 6045334456}
  def initialize(name, email, id=nil, phone_number=nil)
    @name = name
    @email = email
    @id = id
    @phone_number = phone_number
  end
  
  def self.connection
    CONN
  end

  # Returns an Array of Contacts loaded from the database.
  def self.all
    results = CONN.exec("SELECT c.id, c.name, c.email, p.type, p.number 
      FROM contacts AS c LEFT JOIN phone_numbers AS p 
        ON (c.id = p.contact_id) ORDER BY c.id;")
    process_results(results)
  end

  # Creates a new contact and saves the contact to the database, returning the new contact.
  def self.create(name, email, phone_number)
    contact = Contact.new(name, email, phone_number)
    contact.save
    phone_number.each do |type, phone_number|
      PhoneNumber.create(type.to_s, phone_number, contact.id)
    end
    contact
  end

  # Returns the contact with the specified id. If no contact has the id, returns nil.
  def self.find(id)
    result = CONN.exec_params("SELECT c.id, c.name, c.email, p.type, p.number 
      FROM contacts AS c LEFT JOIN phone_numbers AS p 
        ON (c.id = p.contact_id) WHERE c.id = $1::int LIMIT 1;", [id])
    begin
      Contact.new(result[0]["name"], result[0]["email"], result[0]["id"])
      rescue IndexError
    end
  end

  # Returns an array of Contacts who match the given key and value.
  def self.search(key, value)
    results = CONN.exec_params("SELECT c.id, c.name, c.email, p.type, p.number 
      FROM contacts AS c LEFT JOIN phone_numbers AS p 
        ON (c.id = p.contact_id) WHERE c.#{key} = $1 ORDER BY c.id;", [value])
    # results = CONN.exec_params("SELECT * FROM contacts WHERE #{key} = $1 ORDER BY id;", [value])
    process_results(results)
  end

  def self.process_results(results)
    contacts = []
    results.each do |contact|
      phone_number = {}
      if contacts.find { |entries| entries[contact["id"].to_sym] }
        contact_to_update = contacts.find { |entries| entries[contact["id"].to_sym] }[contact["id"].to_sym]
        phone_number_to_update = contact_to_update.phone_number
        phone_number_to_update[contact["type"].to_sym] = contact["number"]
      elsif contact["type"]
        type = contact["type"].to_sym
        number = contact["number"]
        phone_number[type] = number
        contacts << { contact["id"].to_sym => Contact.new(contact["name"], contact["email"], contact["id"], phone_number) }
      else
        contacts << { contact["id"].to_sym => Contact.new(contact["name"], contact["email"], contact["id"]) }
      end
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
      contact = CONN.exec_params("INSERT INTO contacts(name, email) VALUES ($1, $2) RETURNING id;", [@name, @email])
      @id = contact[0]["id"]
    end
  end

  def destroy
    CONN.exec_params("DELETE FROM contacts WHERE id = $1::int;", [@id])
  end

end