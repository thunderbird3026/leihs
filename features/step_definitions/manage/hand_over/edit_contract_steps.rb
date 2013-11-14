When /^I select all lines$/ do
  all(".line").each do |line|
    cb = line.find("input[type=checkbox][data-select-line]")
    cb.click unless cb.checked?
  end
  all(".line input[type=checkbox][data-select-line]").all? {|x| x.checked? }.should be_true
end

When /^I change the time range for all contract lines, envolving option and item lines$/ do
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'I select all lines'
  step 'I edit the timerange of the selection'
  @line = @hand_over.lines.first
  @old_start_date = @line.start_date
  @new_start_date = if @line.start_date + 1.day < Date.today
      Date.today
    else
      @line.start_date + 1.day
  end
  get_fullcalendar_day_element(@new_start_date).click
  find("#set-start-date", :text => _("Start Date")).click
  step 'I save the booking calendar'
end

Then /^the time range for all contract lines is changed$/ do
  @customer.visits.hand_over.detect{|x| x.lines.size > 1}.lines.each do |line|
    line.start_date.should == @new_start_date
  end
end

When /^I change the time range for that option$/ do
  @option_line = @customer.visits.hand_over.collect(&:lines).flatten.detect{|x| x.is_a?(OptionLine)}
  find(".line[data-line-type='option_line']", :text => @option_line.option.name).find(".button", :text => _("Change entry")).click
  @new_start_date = change_line_start_date(@option_line, 2)
end

Then /^the time range for that option line is changed$/ do
  @option_line.reload.start_date.should == @new_start_date
end

When(/^I add an option$/) do
  @option = Option.find_by_inventory_pool_id @current_inventory_pool.id
  field_value = @option.name
  find("[data-add-contract-line]").set field_value
  step "ensure there are no active requests"
  find("[role='menuitem'] a[title='#{field_value}']", match: :prefer_exact, text: field_value).click
  step "ensure there are no active requests"
  @option_line = OptionLine.find find(".line[data-line-type='option_line']", match: :prefer_exact, text: @option.name)["data-id"]
end

When(/^I change the quantity right on the line$/) do
  @quantity = rand(2..9)
  within(".line[data-line-type='option_line'][data-id='#{@option_line.id}']") do
    find("input[data-line-quantity]").set @quantity
    step "ensure there are no active requests"
    sleep(0.88)
    find("input[data-line-quantity]").value.should == @quantity.to_s
  end
end

When(/^I decrease the quantity again$/) do
  @quantity -= 1
  step 'I change the quantity right on the line'
end

Then(/^the quantity for that option line is changed$/) do
  @option_line.reload.quantity.should == @quantity
end