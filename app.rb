require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require "./models"

enable :sessions

configure :development do
  set :database, "sqlite3:app.db"
  end
  
  configure :production do
   set :database, ENV["DATABASE_URL"]
  end

  
get "/" do
  if session[:user_id]
    @posts = User.find(session[:user_id]).posts
    erb :signed_in
  else
    erb :signed_out
  end
end



get "/myposts" do
  if session[:user_id]
    @user = User.find(session[:user_id])
    @posts = @user.posts
  erb :myposts
    else
  redirect "/"
  # erb :profile
  end
end


get "/myposts/:id" do
  @post = Post.find(params[:id])
  @posts = User.find(params[:id]).posts

   erb :myposts
end

post '/myposts' do
   @user = User.find(session[:user_id])
   redirect '/'
end

get "/livefeed" do
  @user = User.find_by(params[:id])
  @posts = @user.posts
  @posts = Post.all
  erb :livefeed
end


post "/livefeed" do
  Post.create(
    title: params[:title],
    subject: params[:subject],
    content: params[:content],
    user_id: session[:user_id]
  )
  redirect '/livefeed'
end

# displays sign in form
get "/signin" do
  erb :signin
end

# responds to sign in form
post "/signin" do
  @user = User.find_by(username: params[:username])

  # checks to see if the user exists
  #   and also if the user password matches the password in the db
  if @user && @user.password == params[:password]
    # this line signs a user in
    session[:user_id] = @user.id

    # lets the user know that something is wrong
    flash[:info] = "You have been signed in #{params[:username]}."

    # redirects to the home page
    redirect "/livefeed"
  else
    # lets the user know that something is wrong
    flash[:warning] = "Your username or password is incorrect"

    # if user does not exist or password does not match then
    #   redirect the user to the sign in page
    redirect "/"
  end
end

# displays signup form
#   with fields for relevant user information like:
#   username, password
get "/signup" do
  erb :signup
end

post "/signup" do
  @user = User.create(
      username: params[:username],
      password: params[:password],
      first_name: params[:first_name],
      last_name: params[:last_name],
      birthday: params[:birthday],
      email: params[:email]
  )

  # this line does the signing in
  session[:user_id] = @user.id

  # lets the user know they have signed up
  flash[:info] = "Thank you for signing up #{params[:first_name]}!"

  # assuming this page exists
  redirect "/"
end

# when hitting this get path via a link
#   it would reset the session user_id and redirect
#   back to the homepage
get "/signed_out" do
  # this is the line that signs a user out
  session[:user_id] = nil

  # lets the user know they have signed out
  flash[:info] = "You have been signed out."
  
  redirect "/"
end


get "/myprofile/:id" do
  @user = User.find(session[:user_id])
  @posts = @user.posts
    erb :myprofile
end


get "/myprofile" do
  if session[:user_id]
    @user = User.find(session[:user_id])

    erb :myprofile
  else
    redirect "/"
  end
end

# post "/myprofile" do
#   @user = User.find(session[:user_id])



#     title = params[:title]
#     id = session[:user_id]
#     user = User.find(id)
#   if title != user.username
#     redirect '/myprofile'
#   else
#     user.posts.destroy
#     user.profile.destroy
#     user.destroy
#     session[:user_id] = nil
#     redirect '/'
#   end
# end


 
 
 post '/myprofile' do
    @user = User.find(session[:user_id])
 
  if @user.username == params[:username] 
    # && @user.password == params[:password]
    @user.posts.each do |post|
       Post.destroy(post.id)
    end
    User.destroy(session[:user_id])
    session[:user_id] = nil
    flash[:info] = "You have deleted your account"
    redirect "/"
  end
end

get "/deleteuser" do
  if session[:user_id]
      @posts = Post.all
      @posts.each do |post|
          if (post.user_id == session[:user_id] )
              post.destroy
          else
              next
          end  
      end      
      # @id = session[:user_id]
      @user = User.find(session[:user_id]).destroy
      # @posts = Post.find_by(user_id: @id).destroy
      
      session[:user_id] = nil
  end
erb :signin
end

# get "/delete_all_post" do
#   if session[:user_id]
#       @posts = Post.all
#       @posts.each do |post|
#           if (post.user_id == session[:user_id] )
#               post.destroy
#           else
#               next
#           end  
#       end      
#   end
# redirect "/myprofile"
# end

# get "/delete_a_post" do
#   if session[:user_id]
#       Post.find_by(user_id: session[:user_id]).destroy()
      
#   end
# redirect "/myprofile"
# end