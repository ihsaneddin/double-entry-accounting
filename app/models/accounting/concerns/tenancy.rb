module Accounting
  module Concerns
    module Tenancy
      extend ActiveSupport::Concern

      included do

        belongs_to :tenant, class_name: Accounting.tenant_class, optional: true
        validates :name, presence: true, uniqueness: { scope: :tenant_id }

      end
    end
  end
end
