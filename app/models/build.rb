class Build < ActiveRecord::Base
  belongs_to :branch
  has_one :project, through: :branch
  has_many :results, autosave: true, dependent: :destroy

  validates :branch, presence: true

  scope :recent_first, order('created_at DESC')

  before_create :create_default_results

  delegate :git_url, to: :project
  delegate :name, to: :branch, prefix: :branch

  def self.last
    recent_first.limit(1).first
  end

  def self.last_finished
    recent_first.detect { |build| build.finished? }
  end

  def results_in_status(status)
    results.select { |r| r.in_status? status }.count
  end

  def short_hash
    commit_hash.try :[], 0..9
  end

  def duration
    end_time - start_time rescue nil
  end

  def status
    [:busy, :failed, :pending, :skipped].each do |status|
      return status unless results_in_status(status).zero?
    end
    :passed
  end

  Result::STATUS.keys.each do |s|
    define_method "#{s}?" do
      status == s
    end
  end

  def finished?
    passed? || failed?
  end

  def start_time
    results.first.start_time
  end

  def end_time
    results.last.end_time
  end

  def create_default_results
    project.commands.each do |command|
      results.build(:command => command)
    end
  end

  def has_commit_info?
    commit_hash.present? && commit_message.present? && commit_author.present? && commit_date.present?
  end

  def fill_from_hook(params)
    self.branch = params[:ref].match(/\/([^\/]+)$/)[1]
    self.commit_hash = params[:after]
  end

  def should_build?
    branch.should_build? && project.should_build?(self)
  end

  def skip!
    results.each do |result|
      result.skipped
    end
  end

  def delete_jobs_in_queues
    Resque.dequeue(Builder, id)
  end
end
