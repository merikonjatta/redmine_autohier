
Factory.define :project do |o|
  o.name "The Project"
  o.identifier "theproject"
end

Factory.define :wiki do |o|
  o.project Factory.create(:project)
  o.start_page 'StartPage'
end

Factory.define :wiki_page do |o|
  o.wiki Factory.create(:wiki)
  o.title "PageA"
end
