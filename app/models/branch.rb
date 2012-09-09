class Branch < ActiveRecord::Base
  belongs_to :project

  scope :active, where(active: true)
end
