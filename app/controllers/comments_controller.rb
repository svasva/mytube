class CommentsController < ApplicationController
  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.author = current_user
    @comment.save
    redirect_to :back
  end

  def destroy
    c = Comment.find(params[:id])
    c.replies.each { |reply| reply.destroy }
    c.destroy
    redirect_to :back
  end
end
