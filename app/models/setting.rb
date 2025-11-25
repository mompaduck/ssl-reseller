class Setting < ApplicationRecord
  # Simple key-value store for application settings
  
  validates :key, presence: true, uniqueness: true
  
  # Get a setting value with optional default
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting ? setting.value.to_i : default
  end
  
  # Set a setting value
  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.save!
  end
  
  # Get a string setting value
  def self.get_string(key, default = '')
    setting = find_by(key: key)
    setting ? setting.value : default
  end
  
  # Set a string setting value
  def self.set_string(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value.to_s
    setting.save!
  end
  
  # Get a boolean setting value
  def self.get_boolean(key, default = false)
    setting = find_by(key: key)
    return default if setting.nil?
    setting.value.to_s.downcase.in?(['true', '1', 'yes'])
  end
  
  # Set a boolean setting value
  def self.set_boolean(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value ? 'true' : 'false'
    setting.save!
  end
  
  # Delete a setting
  def self.delete_key(key)
    find_by(key: key)&.destroy
  end
end
