class Photo < ActiveRecord::Base
  def self.active
    where(active: true)
  end
end
