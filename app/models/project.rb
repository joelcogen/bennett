class Project < ActiveRecord::Base
  has_many :rights
  has_many :users, through: :rights
  has_many :branches
  has_many :builds, through: :branches, dependent: :destroy
  has_many :commands, dependent: :destroy

  accepts_nested_attributes_for :commands, :branches

  validates :name, :git_url, :hook_token, presence: true
  validate :unique_command_positions

  before_validation :create_hook_token, on: :create

  scope :public, where(public: true)

  def self.build_all_nightly!
    Project.where(build_nightly: true).each do |project|
      build = project.builds.create
      Resque.enqueue(CommitsFetcher, build.id)
    end
  end

  def last_build
    builds.last
  end

  def last_finished_build
    builds.last_finished
  end

  def status
    never_built? ? :no_builds : last_build.status
  end

  def finished_status
    last_finished_build.try :status
  end
  def has_finished_status?
    finished_status.present?
  end

  def has_active_branches?
    branches.active.any?
  end

  def never_built?
    builds.none?
  end

  def busy_or_pending?
    last_build.present? && (last_build.busy? || last_build.pending?)
  end

  def unique_command_positions
    errors.add(:commands, 'must have a non-ambiguous order') unless commands.map(&:position).size == commands.map(&:position).uniq.size
  end

  def fetch_branches
    self.branches = SuperGit.branches_for_url(git_url).map { |branch_name| Branch.new name: branch_name }
  end

  def should_build?(build)
    !(recentizer? && last_build != build)
  end

  private

  def create_hook_token
    self.hook_token = SecureRandom.hex(8)
  end

end
