require 'sinatra'
require 'sinatra/activerecord'
require 'aws-sdk-s3'
require 'dotenv/load'
require 'thin'
require 'byebug'
require 'rufus-scheduler'
# require 'config.ru'
require './models/photo.rb'
require './config/environments'

class App < Sinatra::Base
  enable :sessions

  scheduler = Rufus::Scheduler.new
  scheduler.every '1d' do
    photos = Photo.active
    photos.each do |i|
      d = i.days - 1
      i.update(days: d)
      i.update(active: false) if i.days <= 0
    end
  end

  helpers do
    def loged
      redirect '/' if session[:id].nil?
    end

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

  get '/' do
    erb :login
  end

  post '/' do
    if params[:user] == ENV['USERNAME'] && params[:pass] == ENV['PASS']
      session[:id] = params[:user]
      redirect '/crear'
    else
      "contrasena incorecta porfavor intente denuevo <a href='/'>Inicio</a>"
    end
  end
  get '/index' do
    erb :index
  end

  get '/envivo' do
    loged
    @display = params[:display].to_i unless params[:display].nil?

    @photos = if @display.nil?
                Photo.where(display: 1)
              elsif @display == 7
                Photo.where(todas: true, display: 4)
              else
                Photo.where(display: @display)
            end
    erb :envivo
  end

  post '/envivo' do
    loged

    if params[:display].to_i == 7
      unless params[:activate].nil?
        params[:activate].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp_active = Photo.where(public_url: temp.public_url)
          temp_active.each do |y|
            y.update(active: true)
          end
        end
    end
      unless params[:deactivate].nil?
        params[:deactivate].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp_deactive = Photo.where(public_url: temp.public_url)
          temp_deactive.each do |y|
            y.update(active: false)
          end
        end
      end

      unless params[:delete].nil?
        params[:delete].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp_delete = Photo.where(public_url: temp.public_url)
          client = get_aws_client
          temp_delete.each do |y|
            client.delete_object( bucket: "centralphoto", key: y.photo_name.to_s)
          end
          temp_delete.destroy_all
        end
    end
    else
      unless params[:activate].nil?
        params[:activate].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp.update(active: true)
        end
    end
      unless params[:deactivate].nil?
        params[:deactivate].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp.update(active: false)
        end
    end
      unless params[:delete].nil?
        params[:delete].each do |i|
          temp = Photo.find_by(id: i.to_i)
          temp.delete
        end
    end
end
    redirect '/envivo'
  end

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
    s3 = Aws::S3::Resource.new(access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                               secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
                               region: 'us-east-2')

    params[:file].each do |f|
      file_name = f[:filename]
      upload_all = nil
      upload_file = f[:tempfile]
      days = params[:days].to_i
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
        for i in 1..6
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

  error NoMethodError do
    'Error porfavor volver a la pagina anterior y intente de nuevo'
  end

  get '/display' do
    @photos = Photo.where(active: true)
    erb :display
  end

  get '/display/:did' do
    photo_all = Photo.where(display: params[:did])
    @photos = photo_all.active
    erb :display
  end
  #   get '/deleteall' do
  #     Photo.delete_all
  #     2 + 2
  #     redirect '/'
  #   end
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
end
