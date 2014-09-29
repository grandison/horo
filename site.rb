require 'sinatra'
require 'typhoeus'
require 'nokogiri'

set :protection, :except => :frame_options

class Cache
	def self.get(key)
		@caches ||= {}
		@caches[key]
	end

	def self.set(key,value)
		@caches ||= {}
		@caches[key] = value
		value 
	end
end

def get_prognoz
	pr = Cache.get(Time.now.strftime("%D")) 
	unless pr
		pr = {}
		["vesi", "oven", "strelec", "blizneci", "vodoley", "telec", "deva", "kozerog", "rak", "skorpion", "ribi", "lev"].each do |sign|
			body = Typhoeus.get("http://www.astrostar.ru/goroskopy/na-segodnya/#{sign}").body
			doc = Nokogiri::HTML(body)
			pr[sign] = doc.css("#horo-text p").text
		end
		Cache.set(Time.now.strftime("%D"),pr)
	end
	pr
end

get '/' do
	@prognozes = get_prognoz
	erb :index
end