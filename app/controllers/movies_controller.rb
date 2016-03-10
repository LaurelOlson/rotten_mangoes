class MoviesController < ApplicationController

  def index

    @movie = Movie.new

    text = params[:text] unless params[:text] == ""
    runtime = params[:runtime] unless params[:runtime] == "Runtime"
    if text || runtime # Search
      @movies = []
      if text && Movie.search_text(text)
        @movies << Movie.search_text(text)
      elsif runtime && Movie.search_runtime(runtime)
        @movies << Movie.search_runtime(runtime)
      end
      @movies.flatten!

    else # Show all
      @movies = Movie.all.order(created_at: :desc)
    end

    @movies_info = []

    @movies.each do |movie| 
      movie_display_info = {
        id: movie.id,
        title: movie.title,
        avg_rating: movie.review_average,
        release_date: movie.formatted_release_date,
        poster_url: movie.poster_image.url,
        url: "/movies/#{movie.id}",
        director: movie.director,
        description: movie.description,
        runtime: movie.runtime_in_minutes
      }
      @movies_info << movie_display_info
    end

    if @movies_info.count > 0
      respond_to do |format|
        format.json { render json: { movies: @movies_info }, status: 200 }
        format.html { @movies }
      end
    else
      render json: 'No Results Found', status: :unprocessable_entity
    end

  end

  def show
    # include reviews and review user in movie
    @movie = Movie.includes(reviews: :user).find(params[:id])
    @reviews = @movie.reviews.order(created_at: :desc).page(params[:page]).per(10)
    reviews = []

    @reviews.each do |review|
      review_display_info = {
        text: review.text,
        rating: review.rating_out_of_ten,
        author: review.user.firstname
      }
      reviews << review_display_info
    end

    if current_user
      current_user_name = current_user.firstname.capitalize
    else
      current_user_name = ''
    end

    movie = {
      current_user: current_user_name,
      id: @movie.id,
      poster_url: @movie.poster_image.url,
      title: @movie.title,
      avg_rating: @movie.review_average,
      release_date: @movie.formatted_release_date,
      director: @movie.director,
      runtime: @movie.runtime_in_minutes,
      description: @movie.description
    }

    render json: { movie: movie, reviews: reviews }
    # if current_user
    #   @review = @movie.reviews.build
    #   @review.user_id = current_user.id
    # end
  end

  def new
    @movie = Movie.new
  end

  def edit
    @movie = Movie.find(params[:id])
  end

  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to movies_path, notice: "#{@movie.title} was submitted successfully!"
    else
      render :new
    end
  end

  def update
    @movie = Movie.find(params[:id])

    if @movie.update_attributes(movie_params)
      redirect_to movie_path(@movie)
    else
      render :edit
    end
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    redirect_to movies_path
  end

  protected

  def movie_params
    params.require(:movie).permit(:title, :release_date, :director, :runtime_in_minutes, :poster_image, :description)
  end

end