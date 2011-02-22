module WikiPagePatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
    base.class_eval do |mod|
      alias_method :title_without_autohier=, :title=
      alias_method :title=, :title_with_autohier=
      alias_method :before_save_without_autohier, :before_save
      alias_method :before_save, :before_save_with_autohier
    end
  end

  module InstanceMethods
    def title_with_autohier=(value)
      value = Wiki.titleize_with_autohier(value)
      @previous_title = read_attribute(:title) if @previous_title.blank?
      write_attribute(:title, value)
    end
    
    def before_save_with_autohier
      self.title = Wiki.titleize(title)
      
      # Set the parent page by '>'s in the title
      path = self.title.split(/\>/)
      if path.length > 1
        self.parent_title = path[0...-1].join('>')
      else
        self.parent = nil
      end
      
      # Move the whole tree beneath if the title has changed
      if title != @previous_title
        descendants = WikiPage.find(:all, :conditions=>["title LIKE ?", "#{@previous_title}>%"])
        descendants.each do |d|
          d.title = d.title.gsub(/^#{@previous_title}\>(.*)$/, "#{self.title}>\\1")
          d.save
        end
      end
      
      before_save_without_autohier
    end

    def short_title
      WikiPage.short_title(title)
    end
  end
  
  module ClassMethods
    def short_title(str)
      self.pretty_title(str).split('>').last
    end
  end
end

WikiPage.send(:include, WikiPagePatch)