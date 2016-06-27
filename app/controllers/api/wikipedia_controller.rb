class Api::WikipediaController < ApplicationController

  def search
    begin
      wiki_service = WikipediaService.new
      results = wiki_service.search_by_location(params[:location])
      render json: { status: :success, results: results }
    rescue
      render json: { status: :error }
    end
  end

  def article_preview
    begin
      wiki_service = WikipediaService.new
      preview = wiki_service.get_article_preview(params[:article_id])
      render json: { status: :success, :preview => preview }
    rescue
      render json: { status: :error }
    end
  end

end
