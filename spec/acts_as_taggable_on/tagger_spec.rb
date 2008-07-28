require File.dirname(__FILE__) + '/../spec_helper'

describe "Tagger" do
  before(:each) do
    [TaggableModel, Tag, Tagging, TaggableUser].each(&:delete_all)
    @user = TaggableUser.new
    @user2 = TaggableUser.new
    @taggable = TaggableModel.new(:name => "Bob Jones")
  end
  
  it "should have taggings" do
    @user.tag(@taggable, :with=>'ruby,scheme', :on=>:tags)
    @user.owned_taggings.size == 2
  end
  
  it "should have tags" do
    @user.tag(@taggable, :with=>'ruby,scheme', :on=>:tags)
    @user.owned_tags.size == 2
  end
  
  it "is tagger" do
    @user.is_tagger?.should(be_true)
  end  
  
  it "should be able to tag a taggable with many others owners" do
    @user.tag(@taggable, :with=>'ruby,scheme', :on=>:tags)
    @user2.tag(@taggable, :with=>'sql,css', :on=>:tags)
    
    @taggable.reload
    @taggable.tags_from(@user).to_s.should == 'ruby, scheme'
    @taggable.reload
    @taggable.tags_from(@user2).to_s.should == 'sql, css'
  end
  
  
  it "should not be able to delete a non owned tag" do
    @user.tag(@taggable, :with=>'ruby,scheme', :on=>:tags)
    @user2.tag(@taggable, :with=>'ruby,rubyonrails', :on=>:tags)
    
    @taggable.reload
    @taggable.tags_from(@user).to_s.should == 'ruby, scheme'
    @taggable.reload
    @taggable.tags_from(@user2).to_s.should == 'ruby, rubyonrails'
    
    @user.tag(@taggable, :with=>'merb', :on=>:tags)
    @taggable.reload
    @taggable.tags_from(@user).to_s.should == 'merb'
    @taggable.reload
    @taggable.tags_from(@user2).to_s.should == 'ruby, rubyonrails'
  end
  
  
  it "should have his own tags on taggable" do
    @user.tag(@taggable, :with=>'ruby', :on=>:tags)
    @user2.tag(@taggable, :with=>'ruby,rubyonrails', :on=>:tags)
    @taggable.tag_list.to_s.should == 'ruby, rubyonrails'
    
    @taggable.tag_counts.first.name = 'ruby'
    @taggable.tag_counts.first.count = 2
    
    @taggable.tag_counts.last.name = 'rubyonrails'
    @taggable.tag_counts.last.count = 1
  end
  
end