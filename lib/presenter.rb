# This module is used by the template_controller for additinal functionality 
# - some business logic used by the view
module Presenter

  class Base
    include ActionView::Helpers::TagHelper # link_to
    include ActionView::Helpers::UrlHelper # url_for
    include ActionController::UrlWriter # named routes
    attr_accessor :controller, :website, :permalink # so we can be lazy

    def initialize(args)
      @controller = args[:controller]
      @website = args[:website]
      @permalink = args[:permalink]
    end

    alias :html_escape :h
    def html_escape(s) # I couldn't figure a better way to do this
      s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "\&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;") #>
    end  

  end       

end
