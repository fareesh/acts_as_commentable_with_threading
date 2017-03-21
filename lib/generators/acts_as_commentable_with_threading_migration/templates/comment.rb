class Comment < ActiveRecord::Base
  acts_as_nested_set scope: [:commentable_id, :commentable_type]

  validates :body, presence: true
  validates :visitor, presence: true

  # NOTE: install the acts_as_votable plugin if you
  # want visitor to vote on the quality of comments.
  # acts_as_votable

  belongs_to :commentable, polymorphic: true

  # NOTE: Comments belong to a visitor
  belongs_to :visitor

  # Helper class method that allows you to build a comment
  # by passing a commentable object, a visitor_id, and comment text
  # example in readme
  def self.build_from(obj, visitor_id, comment)
    new \
      commentable: obj,
      body: comment,
      visitor_id: visitor_id
  end

  # helper method to check if a comment has children
  def has_children?
    children.any?
  end

  # Helper class method to lookup all comments assigned
  # to all commentable types for a given visitor.
  scope :find_comments_by_visitor, lambda { |visitor|
    where(visitor_id: visitor.id).order('created_at DESC')
  }

  # Helper class method to look up all comments for
  # commentable class name and commentable id.
  scope :find_comments_for_commentable, lambda { |type, id|
    where(commentable_type: type.to_s, commentable_id: id)
      .order('created_at DESC')
  }

  # Helper class method to look up a commentable object
  # given the commentable class name and id
  def self.find_commentable(commentable_str, commentable_id)
    commentable_str.constantize.find(commentable_id)
  end
end
