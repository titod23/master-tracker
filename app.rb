require "sinatra"
require 'sinatra/flash'
require 'sinatra/reloader'
also_reload('lib/**/*.rb')
require './lib/authentication'
require "stripe"

####
require 'plaid'
#####

set :public_folder, File.dirname(__FILE__) + '/static'
set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']

Stripe.api_key = settings.secret_key

####
client = Plaid::Client.new(env: :sandbox,
                           client_id: ENV['PLAID_CLIENT_ID'],
                           secret: ENV['PLAID_SECRET'],
                           public_key: ENV['PLAID_PUBLIC_KEY'])

access_token = nil
####

#make an admin user if one doesn't exist!
if User.all(administrator: true).count == 0
	u = User.new
	u.email = "admin@admin.com"
	u.password = "admin"
	u.administrator = true
	u.save
end

get "/" do
	erb :index
end

get '/upgrade' do
	authenticate!
	pro_access!
	erb :upgrade
end

post '/charge' do
 	authenticate!
  	# Amount in cents
  	@amount = 500

  	customer = Stripe::Customer.create(
    :email => 'customer@example.com',
    :source  => params[:stripeToken]
  )

  	charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => 'Sinatra Charge',
    :currency    => 'usd',
    :customer    => customer.id
  )

  	current_user.pro = true
  	current_user.save
  	erb :plaid
end

post '/sandbox/public_token/create' do



end