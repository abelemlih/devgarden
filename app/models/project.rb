class Project < ApplicationRecord
  has_many :participations, -> { order(:id) }, dependent: :destroy
  has_many :participants, through: :participations, source: :person

  has_many :role_requests, -> { includes(:role) }, dependent: :destroy
  has_many :requested_roles, through: :role_requests, source: :role
  
  has_many :project_tags, -> { includes(:tag).order(:order) }, dependent: :destroy
  has_many :tags, -> { includes(:category) }, through: :project_tags

  mount_uploader :icon, ProjectIconUploader

  MAX_TAGLINE_LENGTH = 50
  validates :name, presence: true
  validates :tagline, length: { maximum: MAX_TAGLINE_LENGTH }

  URL_REGEXP = URI::regexp(%w(http https))
  validates :url, format: URL_REGEXP, allow_blank: true
  validate :scm_urls_are_urls

  after_save :remove_duplicate_tags
  after_save :remove_duplicate_participants

  accepts_nested_attributes_for :participations

  include RecentScope
  include Themed
  include ConditionallyVisible

  scope :with_scm_url, ->(scm_url) do
    where('scm_urls @> ARRAY[?::character varying]', scm_url)
  end

  def admins_include?(person)
    person && participations.where(person: person, admin: true).any?
  end

  def tags_grouped
    tags
      .visible
      .group_by(&:category)
      .sort_by(&:first)
  end

  include StringArrayAttribute
  exposes_array_as_text :scm_urls, from_text: ->(url) do
    url.gsub(GIT_REPO_FROM_URL, 'https://github.com/\1')
  end

  def github_repos
    scm_urls.map { |url| $1 if url =~ GIT_REPO_FROM_URL}.compact
  end

private

  GIT_REPO_FROM_URL = %r{
      \A
      (?:
        # Several possible prefixes if user copied git URL instead of web URL
        git@github.com:
        | (?: https? | git )://github.com/
      )?
      (
        [\w-]+  # user name
        /
        [\w-]+  # project name
      )
      (\.git)?  # Drop .git suffix if present
      \Z
    }x

  def scm_urls_are_urls
    scm_urls.each do |url|
      unless url =~ URL_REGEXP
        msg = "<b>#{ERB::Util.h url}</b> is not a valid URL"
        errors.add(:scm_urls, msg)
        errors.add(:scm_urls_as_text, msg)
      end
    end
  end

  def remove_duplicate_tags
    self.project_tags = project_tags
      .sort_by(&:order)
      .uniq(&:tag_id)
  end

  def remove_duplicate_participants
    self.participations = participations
      .sort_by { |p| p.admin ? 0 : 1 }  # user is admin if any of their dup entries are
      .uniq(&:person_id)
  end

end
