class Display < ActiveRecord::Base
  has_many :photos

  def update_status
    self.last_call = Time.now
    save
  end
end
