class Game < ActiveRecord::Base
  belongs_to :home_player, class_name: 'User'
  belongs_to :guest_player, class_name: 'User'

  validates :home_player, presence: true
  validates :guest_player, presence: true

  serialize :map
end
