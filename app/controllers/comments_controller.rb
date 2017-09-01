class CommentsController < ApplicationController
  before_action :set_article

  def create
    @article.comments.create(comment_params)
    redirect_back fallback_location: articles_path
  end

  private
    def comment_params
      params.require(:comment).permit(
        :content
      )
    end

    def set_article
      @article = Article.find(params[:article_id])
    end
end
