# -*- encoding : utf-8 -*-

# TODO: for some unknown reason find_or_create_by_ will be returning
# nil within this module. A lot could be improved/simplified here,
# if it actually worked.
#
module LeihsFactory

  ##########################################
  #
  # Creating Models
  #
  ##########################################

  #
  # Building
  # 
  def self.create_building!(attributes) # needs a hash
    Building.create! attributes
  end

  # Location
  # 
  def self.create_location(attributes) # needs a hash
    b = Building.create! :name => attributes[:building]
    attributes.delete :building
    l = Location.create! attributes
    l.building = b
    l.save
    l
  end

  #
  # AuthenticationSystem
  # 
  def self.create_authentication_system!(attributes) # needs a hash
    default_attributes = {
      :is_default => false,
      :is_active  => false
    }
    AuthenticationSystem.create! default_attributes.merge(attributes)
  end

  #
  # Language
  # 
  def self.create_language!(attributes) # needs a hash
    default_attributes = {
      :default => false,
      :active  => true
    }

    if (lang = Language.find_by_name(attributes[:name]))
      lang.update_attributes(:locale_name => attributes[:locale_name])
    else
      Language.create! default_attributes.merge(attributes)
    end
  end

  #
  # User
  # 
  def self.create_user(attributes = {}, options = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
      :language_id => (Language.default_language ? Language.default_language : LanguageFactory.create).id
    }
    default_attributes[:email] = "#{attributes[:login].gsub(' ', '_')}@example.com" if attributes[:login]
    attributes = default_attributes.merge(attributes)

    u = User.find_by_login attributes[:login]
    u ||= FactoryGirl.create :user, attributes

    options[:role] ||= :customer
    options[:inventory_pool] ||= InventoryPool.first
    LeihsFactory.define_role(u, options[:inventory_pool], options[:role])

    u.save

    # if a password is provided, then we create the user in a way that she can log in
    # for real
    if options[:password]
      LeihsFactory.create_db_auth(:login => u.login, :password => options[:password])
    end

    u
  end

  #
  # User
  # 
  def self.create_db_auth(attributes = {}, options = {})
    default_attributes = {
      :login => "jerome",
      :password  => "pass"
    }
    merged_attributes = default_attributes.merge(attributes)
    
    password = merged_attributes[:password]
    u = User.find_by_login merged_attributes[:login]

    d = DatabaseAuthentication.find_by_login u.login
    if d
      d.password = password
      d.password_confirmation = password
    else
      d = DatabaseAuthentication.create!(:login => u.login,
                                         :password              => password,
                                         :password_confirmation => password)
      d.user = u
    end
    d.save!
  end

  #
  # Role
  # 
  def self.define_role(user, inventory_pool, role = :inventory_manager)
    role = role.to_sym
    begin
      user.access_rights.create(:role => role, :inventory_pool => inventory_pool)
    rescue
      # unique index, record already present
    end
    role
  end

  #
  # Date
  # 
  def self.random_future_date
    # future date is within the next 3 years, at earliest tomorrow
    Date.today + rand(3*365).days + 1.day
  end

  #
  # Order
  # 
  #def self.create_order(attributes = {}, options = {})
  #  default_attributes = {
  #    :inventory_pool => create_inventory_pool(:name => "ABC")
  #  }
  #  o = Order.create default_attributes.merge(attributes)
  #  options[:order_lines].times do |i|
  #      model = LeihsFactory.create_model(:name => "model_#{i}" )
  #      quantity = rand(3) + 1
  #      quantity.times {
  #        FactoryGirl.create(:item, :owner => o.inventory_pool, :model => model)
  #      }
  #      d = [ self.random_future_date, self.random_future_date ]
  #      o.add_lines(quantity, model, o.user_id, d.min, d.max )
  #  end if options[:order_lines]
  #  o.save
  #  o
  #end

  #
  # Contract
  # 
  # copied from create_order
  #def self.create_contract(attributes = {}, options = {})
  #  default_attributes = {
  #    :inventory_pool => create_inventory_pool(:name => "ABC")
  #  }
  #  c = Contract.create default_attributes.merge(attributes)
  #  options[:contract_lines].times { |i|
  #      model = LeihsFactory.create_model(:name => "model_#{i}" )
  #      quantity = rand(3) + 1
  #      quantity.times {
  #        FactoryGirl.create(:item, :owner => c.inventory_pool, :model => model)
  #      }
  #      d = [ self.random_future_date, self.random_future_date ]
  #      c.add_lines(quantity, model, c.user_id, d.min, d.max )
  #  } if options[:contract_lines]
  #  c.save
  #  c
  #end
      
  #
  # Model
  # 
  def self.create_model(attributes = {})
    default_attributes = {
      :name => 'model_1'
    }
    attrs = default_attributes.merge(attributes)
    t = Model.create_with(attrs).find_or_create_by(name: attrs[:name])
    t.save
    t
  end

  #
  # inventory code
  # 
  def self.generate_new_unique_inventory_code
    begin
      chars_len = 1
      nums_len = 2
      chars = ("A".."Z").to_a
      nums = ("0".."9").to_a
      code = ""
      1.upto(chars_len) { |i| code << chars[rand(chars.size-1)] }
      1.upto(nums_len) { |i| code << nums[rand(nums.size-1)] }
    end while Item.exists?(:inventory_code => code)
    code
  end
    
  #
  # parsedate
  # 
  def self.parsedate(str)
    match = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})\.?/.match(str)
    unless match
      ret = ParseDate.old_parsedate(str)
    else
      ret = [match[3].to_i, match[2].to_i, match[1].to_i, nil, nil, nil, nil, nil] 
    end
    DateTime.new(ret[0], ret[1], ret[2]) # TODO Date
  end

  #
  # OrderLine
  # 
  #def self.create_order_line(options = {})
  #    model = LeihsFactory.create_model :name => options[:model_name]
  #
  #    if options[:start_date]
  #      start_date = parsedate(options[:start_date])
  #      end_date = start_date + 2.days
  #    else
  #      d = [ self.random_future_date, self.random_future_date ]
  #      start_date = d.min
  #      end_date = d.max
  #    end
  #
  #    ol = OrderLine.new(:quantity => options[:quantity],
  #                       :model_id => model.to_i,
  #                       :start_date => start_date,
  #                       :end_date => end_date,
  #                       :inventory_pool => options[:inventory_pool])
  #    ol
  #end

  #
  # ContractLine
  # 
  #def self.create_contract_line(options = {})
  #    model = LeihsFactory.create_model :name => options[:model_name]
  #
  #    if options[:start_date]
  #      start_date = parsedate(options[:start_date])
  #      end_date = start_date + 2.days
  #    else
  #      d = Array.new
  #      2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
  #      start_date = d.min
  #      end_date = d.max
  #    end
  #
  #    ol = ContractLine.new(:quantity => options[:quantity],
  #                          :model_id => model.to_i,
  #                          :start_date => start_date,
  #                          :end_date => end_date)
  #    ol
  #end

  #
  # InventoryPool
  # 
  def self.create_inventory_pool(attributes = {}, address_attributes = {})
    default_attributes = {
      :name => "ABC",
      :shortname => "ABC",
      :email => "abc@abc.de"
    }
    default_address_attributes = {
      :street => "My Street and Number",
      :zip_code => "12345",
      :city => "Zürich",
      :country_code => "CH"
    }
    ip = InventoryPool.find_by_name default_attributes.merge(attributes)[:name]
    if ip.nil?
      ip = InventoryPool.create default_attributes.merge(attributes)
      # the workday is create through InventoryPool#before_create,
      # then we cannot use InventoryPool.find_or_create_by_name
      ip.workday.update_attributes(:saturday => true, :sunday => true)
      ip.update_address(default_address_attributes.merge(address_attributes))      
    end
    ip
  end

  #
  # InventoryPool workdays
  # 
  def self.create_inventory_pool_default_workdays(attributes = {})
    default_attributes = {
      :name => "ABC",
      :shortname => "ABC",
      :email => "ABC@abc.de"
    }
    ip = InventoryPool.find_or_create_by(name: default_attributes.merge(attributes)[:name])
    ip.update_attributes default_attributes.merge(attributes)
    ip
  end


  #
  # Category
  # 
  def self.create_category(attributes = {})
    default_attributes = {
      :name => 'category'
    }
    attrs = default_attributes.merge(attributes)
    t = Category.create_with(attrs).find_or_create_by(name: attrs[:name])
    t
  end

  ##########################################
  #
  # Various sets of data for different uses
  #
  ##########################################

  #
  # Simple dataset with
  # * manager, customer, model and an item
  #
  def self.create_dataset_simple

    FactoryGirl.create :setting unless Setting.first
    
    inventory_pool = LeihsFactory.create_inventory_pool_default_workdays
        
    # Create Manager
    user = LeihsFactory.create_user( {:login => 'inv_man'},
                                    {:role => :lending_manager,
                                     :inventory_pool => inventory_pool})
    # Create Customer
    customer = LeihsFactory.create_user( {:login => 'customer'},
                                    {:role => :customer,
                                     :inventory_pool => inventory_pool})
    # Create Model and Item
    model = LeihsFactory.create_model(:name => 'holey parachute')
    FactoryGirl.create(:item, :owner => inventory_pool, :model => model)
    
    # Create Authenication System if not already existing
    FactoryGirl.create :authentication_system, :name => "DatabaseAuthentication" unless AuthenticationSystem.default_system.first

    [inventory_pool, user, customer, model]
  end

  #
  # Languages shipped by default
  #
  def self.create_default_languages
    [['English', 'en-GB', true],
     ['Deutsch', 'de-CH', false],
     ['Castellano','es', false],
     ['Züritüütsch','gsw-CH', false]].each do |lang|
        next if Language.exists?(:locale_name => lang[1])
        LeihsFactory.create_language!(:name => lang[0],
                                      :locale_name => lang[1],
                                      :default => (lang[2] and not Language.exists?(:default => true)))
    end
  end
    
  #
  # Authentication systems supported by default
  #
  def self.create_default_authentication_systems
    LeihsFactory.create_default_authentication_system
    LeihsFactory.create_authentication_system! :name => "LDAP Authentication",
                                          :class_name => "LdapAuthentication"

    LeihsFactory.create_authentication_system! :name => "ZHDK Authentication",
                                          :class_name => "Zhdk"
  end

  #
  # default authentication systems
  #
  def self.create_default_authentication_system
    LeihsFactory.create_authentication_system! :name => "Database Authentication",
                                          :class_name => "DatabaseAuthentication",
                                          :is_active => true,
                                          :is_default => true
  end

  #
  # create the super user aka admin
  #
  # TODO tpo: reuse create_user and create_db_auth instead
  def self.create_super_user
    self.create_user( { :email          => "super_user_1@example.com",
                        :login          => "super_user_1" },
                      { :role           => :admin,
                        :password       => "pass",
                        :inventory_pool => nil,            })
  end

  #
  # default buildings
  #
  def self.create_default_building
    LeihsFactory.create_building! :code => 'ZZZ', :name => 'Great Pyramid of Giza'
  end

  #
  # zhdk buildings
  #
  def self.create_zhdk_building
    [["ZO",  "Andere Non-ZHDK Addresse"],
     ["ZP",  "Heimadresse des Benutzern"],
     ["ZZ",  "Nicht spezifizierte Adresse"],
     ["SQ",  "Ausstellungsstrasse, 60"],
     ["AU",  "Ausstellungsstrasse, 100"],
     ["MC",  "Baslerstrasse, 30 (Mediacampus)"],
     ["FH",  "Florhofgasse, 6"],
     ["FB",  "Förrlibuckstrasse"],
     ["FR",  "Freiestrasse, 56"],
     ["GE",  "Gessnerallee, 11"],
     ["HF",  "Hafnerstrasse, 27"],
     ["HS",  "Hafnerstrasse, 31"],
     ["HA",  "Herostrasse, 5"],
     ["HB",  "Herostrasse, 10"],
     ["HI",  "Hirschengraben, 46"],
     ["KO",  "Limmatstrasse, 57"],
     ["LH",  "Limmatstrasse, 47"],
     ["LI",  "Limmatstrasse, 65"],
     ["LS",  "Limmatstrasse, 45"],
     ["PF",  "Pfingstweidstrasse, 6"],
     ["SE",  "Seefeldstrasse, 225"],
     ["FI",  "Sihlquai, 125"],
     ["PI",  "Sihlquai, 131"],
     ["TP",  "Technoparkstrasse, 1"],
     ["TT",  "Tössertobelstrasse, 1"],
     ["WA",  "Waldmannstrasse, 12"],
     #
     ["DG",  "Hafnerstrasse, 41"],
     ["DI",  "Hafnerstrasse, 39"],
     ["FOE", "Förrlibuckstrasse, 62"],
     ["P5",  "Hardturmstrasse, 11"],
     ["MB",  "Höschgasse 3"],
     ["VE",  "Höschgasse 4"],
     ["MCA", "Baslerstrasse, 30"],
     ["FLG", "Florhofgasse, 6"],
     ["HI1", "Hirschengraben, 1"],
     ["HI20","Hirschengraben, 20"],
     ["HI46","Hirschengraben, 46"],
     ["FRS", "Freiestrasse, 56"],
     ["SFS", "Seefeldstrasse, 225"],
     ["GA9", "Gessnerallee, 9"],
     ["GA11","Gessnerallee, 11"],
     ["GA13","Gessnerallee, 13"],
     ["Z3",  "Militärstrasse, 47"],
     ["FLS", "Florastrasse, 52"],
     ["MES", "Merkurstrasse, 61"],
     ["FLU", "Flurstrasse, 85"],
     ["ARS", "Albisriederstr. 184B"],
     ["TOE", "Tösstobelstrasse, 1"],
     ["RY82","Rychenberg, 82"],
     ["RY94","Rychenberg, 94"],
     ["RY96","Rychenberg, 96-100"],
     ["IFS", "Ifangstrasse, 2"],
     ["BU",  "Schützenmattstrsse, 1B"],
     ["KST", "Kart-Stauffer-Strasse, 26"]].each do |building|
    
       LeihsFactory.create_building! :code => building[0], :name => building[1]
    end
  end

  def self.create_minimal_setup
    LeihsFactory.create_default_languages
    LeihsFactory.create_default_authentication_systems
    superuser = LeihsFactory.create_super_user
    puts _("The administrator %{a} has been created ") % { :a => superuser.login }
    LeihsFactory.create_default_building
  end
end
