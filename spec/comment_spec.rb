require File.expand_path('./spec_helper', File.dirname(__FILE__))

# Specs some of the behavior of awesome_nested_set although does so to
# demonstrate the use of this gem
describe Comment do
  before do
    @visitor = Visitor.create!
    @comment = Comment.create!(body: 'Root comment', visitor: @visitor)
  end

  describe 'that is valid' do
    it 'should have a visitor' do
      expect(@comment.visitor).not_to be_nil
    end

    it 'should have a body' do
      expect(@comment.body).not_to be_nil
    end
  end

  it 'should not have a parent if it is a root Comment' do
    expect(@comment.parent).to be_nil
  end

  it 'can have see how child Comments it has' do
    expect(@comment.children.size).to eq(0)
  end

  it 'can add child Comments' do
    grandchild = Comment.new(body: 'This is a grandchild', visitor: @visitor)
    grandchild.save!
    grandchild.move_to_child_of(@comment)
    expect(@comment.children.size).to eq(1)
  end

  describe 'after having a child added' do
    before do
      @child = Comment.create!(body: 'Child comment', visitor: @visitor)
      @child.move_to_child_of(@comment)
    end

    it 'can be referenced by its child' do
      expect(@child.parent).to eq(@comment)
    end

    it 'can see its child' do
      expect(@comment.children.first).to eq(@child)
    end
  end

  describe 'finders' do
    describe '#find_comments_by_visitor' do
      before :each do
        @other_visitor = Visitor.create!
        @visitor_comment = Comment.create!(body: 'Child comment', visitor: @visitor)
        @non_visitor_comment = Comment.create!(body: 'Child comment',
                                            visitor: @other_visitor)
        @comments = Comment.find_comments_by_visitor(@visitor)
      end

      it 'should return all the comments created by the passed visitor' do
        expect(@comments).to include(@visitor_comment)
      end

      it 'should not return comments created by non-passed visitors' do
        expect(@comments).not_to include(@non_visitor_comment)
      end
    end

    describe '#find_comments_for_commentable' do
      before :each do
        @other_visitor = Visitor.create!
        @visitor_comment =
          Comment.create!(body: 'from visitor',
                          commentable_type: @other_visitor.class.to_s,
                          commentable_id: @other_visitor.id,
                          visitor: @visitor)

        @other_comment =
          Comment.create!(body: 'from other visitor',
                          commentable_type: @visitor.class.to_s,
                          commentable_id: @visitor.id,
                          visitor: @other_visitor)

        @comments =
          Comment.find_comments_for_commentable(@other_visitor.class,
                                                @other_visitor.id)
      end

      it 'should return the comments for the passed commentable' do
        expect(@comments).to include(@visitor_comment)
      end

      it 'should not return the comments for non-passed commentables' do
        expect(@comments).not_to include(@other_comment)
      end
    end
  end
end
