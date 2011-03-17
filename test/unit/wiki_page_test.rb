require File.dirname(__FILE__) + '/../test_helper'

class WikiPageTest < ActiveSupport::TestCase

  def setup
    WikiContent.destroy_all
    WikiRedirect.destroy_all
    WikiPage.destroy_all
    Wiki.destroy_all
    Project.destroy_all
  end


  test "Set parent by > in title on creation" do
    a = Factory(:wiki_page, :title=>"A")
    b = Factory(:wiki_page, :title=>"A>B", :wiki=>a.wiki)
    assert_equal(a, b.parent)
  end


  test "Set parent by > in title on rename" do
    a = Factory(:wiki_page, :title=>"A")
    b = Factory(:wiki_page, :title=>"B", :wiki=>a.wiki)
    b.title = "A>B"
    b.save
    assert_equal(a, b.parent)
  end


  test "Parent is not set when not exists" do
    b = Factory(:wiki_page, :title=>"A>B")
    b.reload
    assert_equal("A>B", b.title)
    assert_nil(b.parent)
  end


  test "Pages in other projects' wikis are not set as parent" do
    pj_a = Factory(:project, :name=>"PJ-A", :identifier=>"pja")
    pj_b = Factory(:project, :name=>"PJ-B", :identifier=>"pjb")

    a = Factory(:wiki_page, :title=>"A", :wiki=>Factory(:wiki, :project=>pj_a))
    b = Factory(:wiki_page, :title=>"B", :wiki=>Factory(:wiki, :project=>pj_b))

    b.title = "A>B"
    b.save
    b.reload
    assert_nil(b.parent)
  end


  test "Tree is moved recursively" do
    wiki = Factory(:wiki)
    a = Factory(:wiki_page, :title=>"A", :wiki=>wiki)
    b = Factory(:wiki_page, :title=>"A>B", :wiki=>wiki)
    c = Factory(:wiki_page, :title=>"A>B>C", :wiki=>a.wiki)
    d = Factory(:wiki_page, :title=>"A>B>D", :wiki=>a.wiki)
    z = Factory(:wiki_page, :title=>"Z", :wiki=>a.wiki)
    
    a.title = "Z>A"
    a.save
    b.reload; c.reload; d.reload
    assert_equal("Z>A>B",   b.title)
    assert_equal(a, b.parent)
    assert_equal("Z>A>B>C", c.title)
    assert_equal(b, c.parent)
    assert_equal("Z>A>B>D", d.title)
    assert_equal(b, d.parent)
  end


  test "Pages in other projects' wikis are not affected on recursive move" do
    wiki_a = Factory(:wiki, :project=>Factory(:project, :name=>"PJA", :identifier=>"pja"))
    wiki_b = Factory(:wiki, :project=>Factory(:project, :name=>"PJB", :identifier=>"pjb"))

    aa = Factory(:wiki_page, :title=>"A", :wiki=>wiki_a)
    z = Factory(:wiki_page, :title=>"Z", :wiki=>wiki_a)
    ba = Factory(:wiki_page, :title=>"A", :wiki=>wiki_b)
    bb = Factory(:wiki_page, :title=>"A>B", :wiki=>wiki_b)

    aa.title = "Z>A"
    aa.save
    ba.reload; bb.reload;
    assert_equal("A>B", bb.title)
  end


  test "short_title returns basename" do
    a = Factory(:wiki_page, :title=>"A")
    b = Factory(:wiki_page, :title=>"A>B")
    assert_equal("B", b.short_title)
  end

end

