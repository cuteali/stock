class Storehouse < ActiveRecord::Base
  scope :latest, -> { order('created_at DESC') }
end
