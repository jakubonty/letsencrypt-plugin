module LetsencryptPlugin
  class ApplicationController < ActionController::Base
    before_filter :challenge_response, only: [:index]
    before_filter :validate_length, only: [:index]

    def index
      # There is only one item in DB with challenge response from our task
      # we will use it to render plain text response
      render text: @response.response, status: :ok, :layout => false
    end

    private

    def validate_length
      # Challenge request should have at least 128bit
      challenge_failed('Challenge failed - Request has invalid length!') if invalid_length
    end

    def challenge_response
      @response = LetsencryptPlugin.config.challenge_dir_name ? Challenge.new : Challenge.first
      challenge_failed('Challenge failed - Can not get response from database!') if @response.nil?
    end

    def challenge_failed(msg)
      Rails.logger.error(msg)
      render plain: msg, status: :bad_request
    end

    def invalid_length
      params[:challenge].nil? || params[:challenge].length < 16 || params[:challenge].length > 256
    end
  end
end
