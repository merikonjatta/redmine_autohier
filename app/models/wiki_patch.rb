module WikiPatch
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def titleize_with_autohier(title)
      title = title.gsub(/\s+/, '_').gsub(/\//, '>').delete(',./?;|:') if title
      title = (title.slice(0..0).upcase + (title.slice(1..-1) || '')) if title
    end
  end
end

Wiki.send(:include, WikiPatch)