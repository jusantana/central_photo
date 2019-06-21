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
    display = Display.find(params[:display].to_i) unless params[:display].nil?
    ##defaults to screen 1
    @photos = if @display.nil?
                Display.first.photos
              elsif @display == 7
                Photo.where(display_all: true)
              else
                display.photos
            end
    erb :envivo
  end

  post '/envivo' do
    ## Updates screen images.
    loged
    ## if params[:display] is 7 then it
    ## does action on all screens for
    ## specific image
    if params[:display].to_i == 7
      if !params[:activate].nil?
        params[:activate].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photos_active = Photo.where(public_url: photo.public_url)
          photos_active.each do |p|
            p.activate!
          end
        end
      end
    ## Deactivates images that still have days left
      if !params[:deactivate].nil?
        params[:deactivate].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photos_deactive = Photo.where(public_url: photo.public_url)
          photos_deactive.each do |p|
            p.deactivate!
          end
        end
      end

      unless params[:delete].nil?
        params[:delete].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photos_delete = Photo.where(public_url: photo.public_url)
          ## Get aws client from env credentials
          client = get_aws_client
          ## Deletes images from aws bucket
          photos_delete.each do |p|
            client.delete_object( bucket: "centralphoto", key: p.photo_name.to_s)
          end
          photos_delete.destroy_all
        end
    end
    else
      ## does action on image
      ## for specific screen
      ## Activates images for an extra day
      unless params[:activate].nil?
        params[:activate].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photo.update(active: true)
        end
    end
      unless params[:deactivate].nil?
        params[:deactivate].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photo.update(active: false)
        end
    end
      unless params[:delete].nil?
        params[:delete].each do |i|
          photo = Photo.find_by(id: i.to_i)
          photo.delete
        end
    end
end
## once done redirect to edit page
    redirect '/envivo'
  end
## page to add images
  get '/crear' do
    loged
    erb :entrar
  end

  post '/crear' do
    loged
    # assumption
    # Following Environment variables are already set
    # AWS_SECRET_ACCESS_KEY, AWS_REGION
    # Alternative way is mentioned https://github.com/aws/aws-sdk-ruby#configuration-options
    # Create an instance of the Aws::S3::Resource class
    s3 = get_s3_client

    params[:file].each do |f|
      file_name = f[:filename]
      upload_all = nil
      upload_file = f[:tempfile]
      days = params[:days].to_i
      ## if todas is true then upload images
      ## to all screens
      ## else set display to specific screen
      if params[:todas].nil?
        display = params[:display].to_i
      else
        upload_all = true
      end
      # Reference the target object by bucket name and key.
      # Objects live in a bucket and have unique keys that identify the object.
      obj = s3.bucket('centralphoto').object(file_name)
      obj.upload_file(upload_file, acl: 'public-read') # http://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html
      if upload_all.nil?
        # Returns Public URL to the file
        photo = {
          photo_name: file_name,
          days: days,
          public_url: obj.public_url,
          display: display
        }
        photo = Photo.new(photo)
        photo.todas = false
        photo.save
      else
        (1..6).each do |i|
          photo = {
            photo_name: file_name,
            days: days,
            public_url: obj.public_url,
            display: i
          }
          photo = Photo.new(photo)
          photo.todas = true
          photo.save
        end
    end
    end

    "Subida las fotos!! <a href='/crear'>Volver</a>"
    # Reference http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpRuby.html
  end

  get '/display' do
    @photos = Photo.where(active: true)
    erb :display
  end

  get '/display/:did' do
    @photos = Photo.where(display: params[:did], active: true)
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
