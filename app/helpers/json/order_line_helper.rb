module Json
  module OrderLineHelper

    def hash_for_order_line(line, with = nil)
      h = {
        type: "order_line",
        id: line.id
      }
      
      if with ||= nil
        [:model, :is_available, :inventory_pool_id, :quantity].each do |k|
          h[k] = line.send(k) if with[k]
        end
      
        if with[:order]
          h[:order] = hash_for line.order, with[:order] 
        end
        
        if with[:availability_for_inventory_pool]
          borrowable_items = line.model.items.scoped_by_inventory_pool_id(current_inventory_pool).borrowable
          h[:total_rentable] = borrowable_items.count
          h[:total_rentable_in_stock] = borrowable_items.in_stock.count
          h[:availability_for_inventory_pool] = {
            :partitions => (line.model.partitions.in(current_inventory_pool).by_groups(current_inventory_pool.groups) + line.model.partitions.in(current_inventory_pool).by_groups(Group::GENERAL_GROUP_ID)).as_json(:include => :group),
            :availability => line.model.availability_changes_in(current_inventory_pool).changes.available_total_quantities
          }
        end
        
        if with[:dates]
          h[:start_date] = line.start_date
          h[:end_date] = line.end_date
        end
      end
      
      h
    end

  end
end