class Sites::Presenter
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
