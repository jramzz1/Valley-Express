#Valley Express by Jesus Ramirez
#for HackSTX 2019

require "sinatra"
require 'data_mapper'
require 'sinatra/flash'
require_relative "authentication.rb"

#Database setup
if ENV['DATABASE_URL']
  DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
  DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

#Menu Items class
class TripDriver
	include DataMapper::Resource
	property :id, Serial								#Object ID
	property :driver_id, Integer						#Contains Driver ID
	property :trip_title, Text							#Contains the Title of the trip
	property :time, Text								#Contains the Time Leaving
	property :phone, Integer							#Driver Phone #
	property :trip_price, Integer						#Contains the Price for the trip
	property :available, Boolean, :default => true		#Used for updating if commute is available
end

#CustomerOrders class
class TripPassenger
	include DataMapper::Resource
	property :id, Serial								#Object ID
	property :user_id, Integer							#Contains User ID
	property :commute_price, Integer					#Contains the Price of the trip
	property :commute_time, Integer						#Contains the Time Leaving
	property :commute_phone, Integer					#Passenger Phone #
	property :commute_title, Text						#Contains the Title of the trip
	property :driver_id, Integer						#Contains the ID of the driver
	property :completed, Boolean, :default => false		#Determines if the trip is completed
end

#Database finalize
DataMapper.finalize
TripDriver.auto_upgrade!
TripPassenger.auto_upgrade!

# Gets information for new trip
get "/new_trip" do
	authenticate!

	erb :new_trip
end

# Creates a new trip
post "/new_trip/create" do
	authenticate!

	if params["title"] != ""
		m = TripDriver.new
		m.driver_id = current_user.id
		m.trip_title = params["title"]
		m.trip_price = params["price"]
		m.time = params["time"]
		m.phone = params["phone"]
		m.save

		flash[:success] = "Success: Your trip has been posted."
		redirect "/"
	else
		flash[:error] = "Error: Missing Information."
		redirect "/new_trip"
	end
end

post "/bookit" do
	authenticate!

	t = TripPassenger.new
	t.id = params["trip_id"]
	t.commute_title = params["trip_title"]
	t.user_id = params["user_id"]
	t.commute_price = params["trip_price"]
	t.commute_time = params["trip_time"]
	t.driver_id = params["driver_id"]
	t.commute_phone = params["driver_phone"]
	t.save

	flash[:success] = "Success: You have booked a ride."
	redirect "/"
end

# Gets all trips
get "/trips" do
	authenticate!

	@trips = TripDriver.all(available: true)
	@users = User.all
	erb :display_trips
end

# About Us page
get "/about-us" do
	erb :about
end

# Homepage
get "/" do
	erb :index
end
