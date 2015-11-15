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
    sort = params[:sort] || session[:sort]
    if params[:ratings]
      @filter_string = []
      params[:ratings].each_key do |key|
        @filter_string << key
      end
      session[:ratings] = @filter_string
    elsif session[:ratings]
      @filter_string = session[:ratings]
    else
      @filter_string = ['G','PG','PG-13','R']
    end
    @all_ratings = Movie.all_ratings

    if params[:sort] != session[:sort]
      session[:sort] = sort
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end

    if params[:sort] == 'Title'
      @title_class = 'hilite'
      @movies = Movie.rating_filtered(@filter_string).order("title")
    elsif params[:sort] == 'Release'
      @release_class = 'hilite'
      @movies = Movie.rating_filtered(@filter_string).order("release_date")
    else
      @title_class = ''
      @release_class = ''
      @movies = Movie.rating_filtered(@filter_string)
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
