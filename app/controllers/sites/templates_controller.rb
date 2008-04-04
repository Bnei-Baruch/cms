class Sites::TemplatesController < ApplicationController
  def show
    # render :text => request.host.to_s + "<br /> Prefix: " + params[:prefix] + "<br /> Prefix: " + params[:id]
    host = 'http://' + request.host
    prefix = params[:prefix]
    permalink = params[:id]
    website = Website.find(:first, :conditions => "domain = '#{host}' and prefix = '#{prefix}'")

    args = {:permalink => permalink, :website=> website, :controller => self}
    @presenter = get_presenter(website.hrid, args)

    unless @presenter.node
      status_404
      return
      # debugger
    end

    respond_to do |format|
      format.html { render :template => @presenter.node_template_path, :layout => @presenter.node_layout_path }
      # format.xml  { render :xml => @page.to_xml }
    end


  end
  
  def redirect_301(url)
		headers["Status"] = '301 Moved Permanently'
		redirect_to url
  end

  def redirect_302(url)
		headers["Status"] = '302 Moved Temporarily'
		redirect_to url
  end

  def status_404
		render :template => @presenter.error_path('status_404'), :status => 404, :layout => false
  end
  

  private     

  def get_presenter(sitename, args)
    sitename = sitename.camelize
    if File.exists?("#{RAILS_ROOT}/app/models/sites/#{sitename}")
      sitename.new(args)
    else
      Global.new(args)
    end  
  end
end
