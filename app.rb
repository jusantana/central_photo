require 'sinatra'
require 'sinatra/activerecord'
require 'aws-sdk-s3'
require 'dotenv/load'
require 'thin'
require 'byebug'
require 'rufus-scheduler'
# require 'config.ru'
require './models/display.rb'
require './models/photo.rb'
require './config/environments'

class App < Sinatra::Base
  enable :sessions

## Schedules job to subtract a
## day from every active picture
## and deactivates image if days reaches 0
  scheduler = Rufus::Scheduler.new
  scheduler.every '1d' do
    Photo.subtract_day!
  end

  helpers do
    def loged
      ## When attempted to go to any page
      ## while not logged in redirects to home
      redirect '/' if session[:id].nil?
    end
      ## Requires https
    def https_required!
      if settings.production? && request.scheme == 'http'
        headers['Location'] = request.url.sub('http', 'https')
        halt 301, "https required\n"
      end
    end
  end

  before do
    https_required!
  end
    #login page
  get '/' do
    erb :login
  end

    ## App has one hard coded user
    ## per client request
  post '/' do
    if params[:user] == ENV['USERNAME'] && params[:pass] == ENV['PASS']
    ## stores session to remember user is logged in
      session[:id] = params[:user]
      ## Rediricts to create if successful
      redirect '/crear'
    else
      "contrasena incorecta porfavor intente denuevo <a href='/'>Inicio</a>"
    end
  end

    ## This page shows displays and pictures
    ## assigned to screen
    ## accepts param display to show specific screen
  get '/envivo' do
    loged
    @display = params[:display] unless params[:display].nil?
    ## defaults to screen 1
    @photos = if @display.nil?
                Display.first.photos
              elsif @display == 'todas'
                Photo.where(display_all: true)
              else
                display = Display.find_by(display_id: @display)
                display.photos
            end

    erb :envivo
  end

  post '/envivo' do
    ## Updates screen images.
    loged
    photo_ids = params[:photo_ids]

      photo_ids.each do |key|
        photo = Photo.find key.to_i
        action = params[key].nil? ? false : params[key][:action]
        case action
        when false
          next
        when 'activate'
          photo.activate!
        when 'deactivate'
          photo.deactivate!
        when 'delete'
         ## Deletes images from aws bucket
          client = get_aws_client
          client.delete_object( bucket: "centralphoto", key: photo.photo_name.to_s)
          photo.destroy
        else
          raise ArgumentError.new("param #{action} is not recognized")
        end
     end
## once done redirect to edit page
    redirect back
  end
## page to add images
  get '/crear' do
    loged
    erb :entrar
  end

  post '/crear' do
    loged

      upload_all = nil
      if params[:todas].nil?
        display = Display.find_by(display_id: params[:display].to_i)
      else
        upload_all = true
      end
      days = params[:days].to_i
    # Create an instance of the Aws::S3::Resource class
    s3 = get_s3_client

    params[:file].each do |f|
      file_name = f[:filename]

      upload_file = f[:tempfile]
      # Reference the target object by bucket name and key.
      # Objects live in a bucket and have unique keys that identify the object.
      obj = s3.bucket('centralphoto').object(file_name)
      obj.upload_file(upload_file, acl: 'public-read') # http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
        photo = Photo.new(
          photo_name: file_name,
          days: days,
          public_url: obj.public_url
        )
      if upload_all.nil?
        photo.display = display
      else
        photo.display_all = true
      end
        photo.save
    end

    redirect '/envivo'
    # Reference http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpRuby.html
  end

  get '/display' do
    @photos = Photo.where(active: true)
    erb :display
  end

  get '/display/:did' do
    @photos = Display.find_by(display_id: params[:did]).photos.active + Photo.where(display_all: true)
    erb :display
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

   private

   def get_aws_client
     Aws::S3::Client.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                         secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                         region: 'us-east-2')
   end

   def get_s3_client
     Aws::S3::Resource.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                           secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                           region: 'us-east-2')
   end

end
