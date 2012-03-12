require 'spec_helper'
require "rspec/expectations"

require "#{Rails.root}/features/support/leihs_factory.rb"


# It seems really hard to test our controllers (?)
# Remove this file if you think it's too hard, and test by model.

# What do we describe, the mailer model or the controller that uses it? Huh?
describe Backend::AcknowledgeController do

# Check e-mails like this after issuing them:  
#   @emails = ActionMailer::Base.deliveries
#   @emails.count.should == num.to_i
#   @emails[index].subject.should == subject
  
  before(:all) do
    @ip = LeihsFactory.create_inventory_pool
    u = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
    @borrowing_user = u
    
    admin_user = LeihsFactory.create_user({:login => 'admin', :email => 'admin@example.com'}, 
                                     {:password => 'barbarbar', :role => 'admin', :inventory_pool => @ip})
    current_user = admin_user
  end
  
  before(:each) do
  end
  
  it "should do nothing" do
    true.should == true
  end
  
  describe "approving an order" do
    it "should send a confirmation e-mail to the user when their order is confirmed" do
      # That doesn't work. we need to post to approve something, and then check if it sends e-mail
      #post "/backend/inventory_pools/#{@ip.id}/approve"
      
    end
  end
  
  
end