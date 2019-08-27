class SessionsBlacklistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_session_blacklist, only: %i[edit update destroy]

  def index
    @sessions_blacklists = SessionsBlacklist.list(params)
  end

  def new
    @sessions_blacklist = SessionsBlacklist.new
  end

  def create
    @sessions_blacklist = SessionsBlacklist.new session_blacklist_params
    if @sessions_blacklist.save
      redirect_to sessions_blacklists_url,
                  notice: t('sessions_blacklists.create.notice')
    else
      render :new
    end
  end

  def edit
    # Intentionally left blank.
  end

  def update
    if @sessions_blacklist.update session_blacklist_params
      redirect_to sessions_blacklists_url,
                  notice: t('sessions_blacklists.update.notice')
    else
      render :edit
    end
  end

  def destroy
    @sessions_blacklist.destroy
    redirect_to :sessions_blacklists, notice: t('sessions_blacklists.destroy.notice')
  end

  private

  def session_blacklist_params
    params.require(:sessions_blacklist).permit(:sessionid)
  end

  def set_session_blacklist
    @sessions_blacklist = SessionsBlacklist.find(params[:id])
  end
end
