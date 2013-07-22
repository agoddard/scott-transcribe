require 'rubygems'
require 'sinatra'
require 'haml'
require 'data_mapper'

# Helpers
require './lib/render_partial'

# Set Sinatra variables
set :app_file, __FILE__
set :root, File.dirname(__FILE__)
set :views, 'views'
set :public_folder, 'public'
set :haml, {:format => :html5} # default Haml format is :xhtml
ENV['TZ'] = 'UTC' # we want to keep everything UTC


require "#{settings.root}/db.rb"


def convert_date(day,month,time) #returns UTC DateTime
  hour,min = time.split(".").map{|a|a.to_i}
  if month == 11 || month == 12
    year = 1911
  else
    year = 1912
  end
  DateTime.new(year,month,day,hour,min,00,'+0')
end

def format_time(time)
  if time.hour == 0
    time.strftime("Day: %B %d, Time: Midt.")
  elsif time.hour == 12
    time.strftime("Day: %B %d, Time: Noon.")
  else
    time.strftime("Day: %B %d, Time: %-H.%M (%p)")
  end
end

@@pages = Page.all.map{|p| p.id}

get '/' do
  haml :index, :layout => :'layouts/application'
end

get '/begin/?' do
 redirect "/transcribe/observations/"
end

get '/transcribe/observations/?' do
  #only grab Recods that have less than 4 observations, unless limit is set 
  if params[:limit] == "single" # pre-production only #TODO remove in production
    record = Record.all.select { |record|  record.observations.count == 0 }.sample
  else
    record = Record.all.select { |record|  record.observations.count < 4 }.sample
  end
  unless record.nil?
    haml :page, :layout => :'layouts/application', :locals => {:record_id => record.id, :time => record.time, :page => record.page.id, :formatted_time => format_time(record.time)}
  else
    haml :finished, :layout => :'layouts/application'
  end
end


get '/transcribe/dates/:page' do
  # get existing records for this page
  if @@pages.include? params[:page]
    existing = Page.first(:id => params[:page]).records.sort_by {|record| record.time}
    haml :date, :layout => :'layouts/application', :locals => {:page => params[:page], :existing => existing}
  else
    redirect "/transcribe/dates/#{@@pages.sample}"
  end  
end

post '/transcribe/dates/:page' do
  page = Page.get(params['page']) || Page.all.sample
  time = convert_date(params['day'].to_i,params['month'].to_i,params['time'])
  Record.create(:page => page, :time => time, :created_at => Time.now, :updated_at => Time.now)
  redirect "/transcribe/dates/#{params['page']}"
end

post '/transcribe/observations/' do
  page = Page.get(params['page'])
  record = Record.get(params['record'])
  Observation.create(
  :record => record,
  :position_camp => params['position_camp'],
  :position_lat => params['position_lat'],
  :position_long => params['position_long'],
  :barometer => params['barometer'],
  :temp => params['temp'],
  :wind_direction => params['wind_direction'],
  :wind_force => params['wind_force'],
  :beaufort => params['beaufort'],
  :cloud_amount => params['cloud_amount'],
  :cloud_kind => params['cloud_kind'],
  :cloud_direction_upper => params['cloud_direction_upper'],
  :cloud_direction_lower => params['cloud_direction_lower'],
  :minimum_temp => params['minimum_temp'],
  :remarks => params['remarks'],
  :transcriber => params['transcriber'],
  :ip_address => request.ip
  )
  redirect "/transcribe/observations/#{params['page']}"
end