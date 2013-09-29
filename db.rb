# initialize db connection
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/transcribe.db")

class Observation
  include DataMapper::Resource
  has 1, :record, :through => DataMapper::Resource

  property :id,                     Serial    # An auto-increment integer key
  property :position_camp,          String    # The number of the camp
  property :position_lat,           String   # Latitude South
  property :position_long,          String   # Longitude East
  property :barometer,              String   # Barometer, in inches
  property :temp,                   String   # Dry Bulb Temp
  property :wind_direction,         String   # Wind Direction (True)
  property :wind_force,             String   # Wind Force (0-12)
  property :beaufort,               String   # Weather (Beaufort Notation)
  property :cloud_amount,           String   # Cloud amount (0-10)
  property :cloud_kind,             String   # Cloud kind
  property :cloud_direction_upper,  String   # Cloud direction from (upper)
  property :cloud_direction_lower,  String   # Cloud direction from (lower)
  property :minimum_temp,           String   # Minimum
  property :remarks,                Text
  property :ip_address,             String   #IP address that added the record
  property :transcriber,            String
  property :created_at,             DateTime
  property :updated_at,             DateTime
end


class Page
  include DataMapper::Resource
  has n, :records, :through => DataMapper::Resource
  
  property :id,                     String, :key => true    # #zoom id of the page (primary key)
  property :page_number,            Integer   # The actual page number from the book
  property :created_at,             DateTime
  property :updated_at,             DateTime
end

class Record
  include DataMapper::Resource
  has n, :observations, :through => DataMapper::Resource
  has 1, :page, :through => DataMapper::Resource
  
  property :id,                     Serial
  property :time,                   DateTime, :unique => true
  property :created_at,             DateTime
  property :updated_at,             DateTime
end



DataMapper.finalize

DataMapper.auto_upgrade!


#populate with initial pages if there are none

unless Page.get('ILhF')
  puts "populating inital pages"
  %w(ILhF ZdzC OuRe lPjf m6l1 wwdrd Bbf4 o0606 CJUN 4c4k 6hiH lTDi mDu1 PGofn tWM4 HZCX N1HB VOHO NFIV VFPa jJWy puLe YdRa g28X tYng).each do |id|
    page = Page.create(
      :id         => id,
      :created_at => Time.now
    )
    page.save!
  end
end