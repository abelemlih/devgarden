class Tag < ApplicationRecord
  belongs_to :category, class_name: "TagCategory"
  has_many :project_tags
  has_many :projects, -> { order('projects.updated_at desc') }, through: :project_tags

  validates :name, uniqueness: { case_sensitive: false }
end
