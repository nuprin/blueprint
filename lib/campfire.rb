require 'rubygems'
require 'tinder'

module Campfire
  SUBDOMAIN = 'causes'
  ROOM_NAME = 'Office'
  USERNAME  = ENV.fetch('CAMPFIRE_USER', 'jimmy@project-agape.com')
  PASSWORD  = ENV.fetch('CAMPFIRE_PASS', 'bagd0nass')

  def self.connect_and_login(user=USERNAME, pass=PASSWORD)
    cf = Tinder::Campfire.new(SUBDOMAIN, :ssl => true)
    cf.login(user, pass)
    cf
  end

  def self.campfire
    @campfire ||= connect_and_login
  end

  def self.room
    @room ||= campfire.find_room_by_name(ROOM_NAME)
  end

  def self.speak(message)
    room.speak(message)
  end

  def self.paste(message)
    room.paste(message)
  end
end
