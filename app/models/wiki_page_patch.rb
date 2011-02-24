module WikiPagePatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend(ClassMethods)
    base.class_eval do |mod|
      alias_method :before_save_without_autohier, :before_save
      alias_method :before_save, :before_save_with_autohier
      alias_method :after_save_without_autohier, :after_save
      alias_method :after_save, :after_save_with_autohier
    end
  end

  module InstanceMethods
    
    # Automatically set the parent page.
    def before_save_with_autohier
      self.title = Wiki.titleize(title)    
      
      # Set the parent page by '>'s in the title
      path = self.title.split(/\>/)
      if path.length > 1
        self.parent_title = path[0...-1].join('>')
      else
        self.parent = nil
      end

      # @previous_title has been set by WikiPage#title=
      # but that will be removed once the original before_save is over.
      # We copy it to another variable so that we can use it in after_save.
      if !@previous_title.blank? && (@previous_title != title) && !new_record?
        @old_title = @previous_title
      end
      
      # Call the original before_save (redirection management etc)
      before_save_without_autohier
    end


    # Move all decendant pages after save
    def after_save_with_autohier
      if !@old_title.blank? && (@old_title != title) && !new_record?
        descendants = self.wiki.pages.find(:all, :conditions=>["title LIKE ?", "#{@old_title}>%"])
        descendants.each do |d|
          d.redirect_existing_links = self.redirect_existing_links
          d.title = d.title.gsub(/^#{@old_title}\>(.*)$/, "#{self.title}>\\1")
          d.save
        end
        @old_title = nil
      end
    end

    # Return the basename of this page's title.
    # Used in the title index, etc
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
