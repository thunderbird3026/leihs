class OrderLine < ActiveRecord::Base
  belongs_to :model
  belongs_to :order
      
  validate :date_sequence

  def date_sequence
    errors.add_to_base("Start Date must be before End Date") if end_date < start_date  
  end
  
  
  
  def self.current_reservations(model_id, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date < ? and end_date > ?', model_id, date, date])
  end
  
  def self.future_reservations(model_id, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and start_date > ?', model_id, date])
  end
  
  def self.current_and_future_reservations(model_id, order_line_id = 0, date = DateTime.now)
    OrderLine.find(:all, :conditions => ['model_id = ? and ((start_date < ? and end_date > ?) or start_date > ?) and id <> ?', model_id, date, date, date, order_line_id])
  end
end
