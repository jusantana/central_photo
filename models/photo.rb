class Photo < ActiveRecord::Base
  belongs_to :display

  def self.active
    where(active: true)
  end

  def self.subtract_day!
    active.each do |p|
      days_remaining = p.days - 1
      p.update(days: days_remaining)
      p.deactivate! if days_remaining == 0
    end
  end

  def deactivate!
    update(active: false)
  end

  def activate!
    update(active: true)
  end

end
