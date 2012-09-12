class Branch < ActiveRecord::Base
  belongs_to :project
  has_many :builds

  scope :active, where(active: true)

  def should_build?
    active? || project.build_all_branches?
  end
end
