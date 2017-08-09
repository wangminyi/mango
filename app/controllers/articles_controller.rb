class ArticlesController < ApplicationController
  before_action :require_login

  layout 'admin'

  def new
    @article = Article.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def create
    @article = current_user.articles.build(article_param)
    if @article.save
      redirect_to articles_path
    else
      render new_article_path
    end
  end

  def index
    @articles = current_user.articles.order(created_at: :desc)
  end

  def edit
    @article = current_user.articles.find(params[:id])
  end

  private
    def article_param
      params.require(:article).permit(
        :title,
        :body,
      )
    end
end
