require File.dirname(__FILE__) + '/../test_helper'

class ApplicationHelperTest < ActionView::TestCase

  def setup
    WikiContent.destroy_all
    WikiRedirect.destroy_all
    WikiPage.destroy_all
    Wiki.destroy_all
    Project.destroy_all
  end

  test "render_page_hierarchy works" do
    w= Factory(:wiki)
    a = Factory(:wiki_page, :title=>"A", :wiki=>w)
    b = Factory(:wiki_page, :title=>"A>B", :wiki=>w)
    c = Factory(:wiki_page, :title=>"A>C", :wiki=>w)
    d = Factory(:wiki_page, :title=>"A>C>D", :wiki=>w)

    # just some simple assertions, making sure there are no errors/exceptions
    w.reload
    display = render_page_hierarchy(w.pages.group_by(&:parent_id))
    assert_equal(4, display.scan(/\<li\>/).count)
  end

  test "breadcrumbs works" do
    w= Factory(:wiki)
    a = Factory(:wiki_page, :title=>"A", :wiki=>w)
    b = Factory(:wiki_page, :title=>"A>B", :wiki=>w)
    c = Factory(:wiki_page, :title=>"A>B>C", :wiki=>w)
    d = Factory(:wiki_page, :title=>"A>B>C>D", :wiki=>w)

    # No assertions, just making sure there are no errors/exceptions
    w.reload
    display = breadcrumb(d.ancestors.reverse.collect {|parent| parent.short_title})
  end

end

