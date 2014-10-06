require 'sinatra'
require 'sinatra/partial'
require 'typhoeus'
require 'nokogiri'
require 'russian'

set :protection, :except => :frame_options
set :partial_template_engine, :erb

def full_name(znak)
	{
		"vodoley" => "Водолей",
		"ribi" => "Рыбы",
		"oven" => "Овен",
		"telec" => "Телец",
		"blizneci" => "Близнецы",
		"rak" => "Рак",
		"lev" => "Лев",
		"deva" => "Дева",
		"vesi" => "Весы",
		"skorpion" => "Скорпион",
		"strelec" => "Стрелец",
		"kozerog" => "Козерог",
	}[znak]
end

def znak_dates(znak)
		{
		"vodoley" => "20 января - 19 февраля",
		"ribi" => "19 февраля - 20 марта",
		"oven" => "21 марта - 19 апреля",
		"telec" => "20 апреля - 20 мая",
		"blizneci" => "21 мая - 20 июня",
		"rak" => "21 июня - 22 июля",
		"lev" => "23 июля - 22 августа",
		"deva" => "23 августа - 22 сентября",
		"vesi" => "23 сентября - 22 октября",
		"skorpion" => "23 октября - 21 ноября",
		"strelec" => "22 ноября - 21 декабря",
		"kozerog" => "22 декабря - 19 января",
	}[znak]
end

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
	@date = Russian::strftime(Time.now, "%d %B")
	@prognozes = get_prognoz
	erb :index
end

get "/popup" do
	@date = Russian::strftime(Time.now, "%d %B")
	@prognozes = get_prognoz
	erb :popup
end

get '/:znak/full' do
	@date = Russian::strftime(Time.now, "%d %B")
	@prognozes = get_prognoz
	partial( :znak_full, :locals => { znak: params[:znak]} )
end

get '/:znak' do
	@prognozes = get_prognoz
	partial( :znak, :locals => { znak: params[:znak]} )
end
