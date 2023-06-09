class FeedsController < ApplicationController
  before_action :set_feed, only: %i[ show edit update destroy ]

  skip_before_action :login_required, only: [:index, :show]

  def index
    @feeds = Feed.all
  end

  def show
    @feed = Feed.find(params[:id])
    @favorite = current_user.favorites.find_by(feed_id: @feed.id)
  end

  def new
    if params[:back]
      @feed = Feed.new(feed_params)
    else
      @feed = Feed.new
    end
  end

  def edit
    unless @feed.user == current_user
      redirect_to new_user_path
    end
  end

  def create
    @feed = Feed.new(feed_params)
    @feed.user_id = current_user.id

    respond_to do |format|
      if @feed.save
        FeedMailer.feed_mail(@feed).deliver
        format.html { redirect_to feed_url(@feed), notice: "Feed was successfully created." }
        format.json { render :show, status: :created, location: @feed }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @feed.update(feed_params)
        format.html { redirect_to feed_url(@feed), notice: "Feed was successfully updated." }
        format.json { render :show, status: :ok, location: @feed }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @feed.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @feed.destroy
    respond_to do |format|
      format.html { redirect_to feeds_url, notice: "Feed was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def confirm
    @feed = Feed.new(feed_params)
    @feed.user_id = current_user.id 
  end

  private   
  def set_feed
    @feed = Feed.find(params[:id])
  end
 
  def feed_params
    params.require(:feed).permit(:image, :image_cache, :content)
  end
end
