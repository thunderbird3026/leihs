module Json
  module OptionLineHelper

    def hash_for_option_line(line, with = nil)
      # TODO (TD) separate optional with
      h = {
        id: line.id,
        type: line.type.underscore,
        start_date: line.start_date,
        end_date: line.end_date,
        quantity: line.quantity,
      
        is_valid: line.valid?,
        
        contract: {
          action: line.contract.action
        },
        
        model: line.option, # this is an alias for option
        item: {
          inventory_code: line.option.inventory_code,
          price: line.option.price
        },
        user: {
          id: line.contract.user_id,
          firstname: line.contract.user.firstname,
          lastname: line.contract.user.lastname,
          groups: line.contract.user.groups
        }
      }
      
      if with ||= nil
        if with[:purpose]
          h[:purpose] = line.purpose ? hash_for(line.purpose, with[:purpose]) : nil
        end
      end
      
      h
    end

  end
end
      