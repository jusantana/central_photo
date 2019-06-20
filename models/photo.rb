class Photo < ActiveRecord::Base
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
    raise ArgumentError.new "Photo still has #{days} days remaining" if days > 0
    update(active: false)
  end


end
