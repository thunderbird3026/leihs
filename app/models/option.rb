# encoding: utf-8
# Options are things that can be borrowed. The are listed
# within #OptionLines which can be added to a #Contract.
# Options don't have their own barcode and thus don't have
# individual identities (contrary to #Item s) and thus can
# be given out by the #InventoryPool manager in arbitrary
# quantities. Also Options are not an instance of some
# #Model as id the case for #Item s.
#
class Option < ActiveRecord::Base

  belongs_to :inventory_pool
  has_many :option_lines

  validates_presence_of :inventory_pool, :name
  validates_uniqueness_of :inventory_code, :scope => :inventory_pool_id, :unless => Proc.new { |record| record.inventory_code.blank? }

  before_validation do |record|
    record.inventory_code = nil if !record.inventory_code.nil? and record.inventory_code.blank? 
  end

##########################################

  scope :search, lambda { |query, fields = []|
    sql = all
    return sql if query.blank?
    
    query.split.each{|q|
      q = "%#{q}%"
      sql = sql.where(arel_table[:name].matches(q).
                      or(arel_table[:inventory_code].matches(q)))
    }
    sql
  }

  def self.filter(params, inventory_pool = nil)
    options = inventory_pool ? inventory_pool.options : all
    options = options.search(params[:search_term], [:name]) unless params[:search_term].blank?
    options = options.where(:id => params[:ids]) if params[:ids]
    options = options.order("#{params[:sort]} #{params[:order]}") if params[:sort] and params[:order]
    options = options.paginate(:page => params[:page]||1, :per_page => [(params[:per_page].try(&:to_i) || 20), 100].min) unless params[:paginate] == "false"
    options
  end

##########################################

  # TODO 2702** before_destroy: check if option_lines.empty?

  def needs_permission?
    false  
  end
  
  def to_s
    name
  end

  # OPTIMIZE we might want a real manufacturer attribute (stored in the db) later on
  def manufacturer
    nil
  end

  # NOTE when we call option_line.item.model, item is actually an option, then model it's itself again
  def model
    self
  end

  # Generates an array suitable for outputting a line of CSV using CSV
  def to_csv_array    
    # Using #{} notation to catch nils gracefully and silently 
    return [ "#{self.inventory_code}",
      "#{self.inventory_pool.try(:name)}",  
      "",
      "",
      "#{self.name}",  
      "",
      "#{_("Option")}",
      "",
      "",
      "",
      "",
      "",
      "#{self.price}",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
    ]
    
  end
 
end
 
