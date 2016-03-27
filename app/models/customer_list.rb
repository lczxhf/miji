class CustomerList < ActiveRecord::Base
	self.table_name = "customer_list"
	self.primary_key = 'openid'
	belongs_to :sangna_config
end
