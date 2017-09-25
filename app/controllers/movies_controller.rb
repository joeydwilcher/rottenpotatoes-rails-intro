class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    
    #session.clear
    
    @all_ratings = Movie.all.uniq.pluck(:rating).sort
    
    if session["ratings"] == nil
      #first access, set up session vars
      session["ratings"] = Hash[@all_ratings.collect { |rating| [rating, "1"] } ]
    end
    
    @included_ratings = params["ratings"] ? params["ratings"] : session["ratings"]
    session["ratings"] = @included_ratings
    
    @movies = Movie.select { |movie| @included_ratings.keys.include? movie.rating }
    
    @title_header_class = ""
    @release_date_header_class = ""

    sort = params["sort"] ? params["sort"] : session["sort"]

    if sort == "title"
      @movies.sort! {|movie1,movie2| movie1.title <=> movie2.title }
      @title_header_class = "hilite"
      session["sort"] = "title"
    elsif sort == "release_date"
      @movies.sort! {|movie1,movie2| movie1.release_date <=> movie2.release_date }
      @release_date_header_class = "hilite"
      session["sort"] = "release_date"
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
