# ActiveAdmin.before_load do |app|
#   ActiveAdmin::Resource.send :include, ActiveAdmin
# end

module ActiveAdmin
  class Comment < ActiveRecord::Base
    after_create :update_resource_if_support_ticket

    private

    def update_resource_if_support_ticket
      if !self.resource.nil? && self.resource.respond_to?('set_state!')
        self.resource.set_state!
      end
    end
  end
end