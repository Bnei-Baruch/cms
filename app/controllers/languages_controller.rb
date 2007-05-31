class LanguagesController < ApplicationController
  # GET /languages
  # GET /languages.xml
  def index
    @languages = Language.find(:all, :order => "id ASC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @languages.to_xml }
    end
  end

  # GET /languages/1
  # GET /languages/1.xml
  def show
    @language = Language.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @language.to_xml }
    end
  end

  # GET /languages/new
  def new
    @language = Language.new
    @label = TextLabel.new(:label_type_id => 33)
  end

  # GET /languages/1;edit
  def edit
    @language = Language.find(params[:id])
    @label = @language.label
  end

  # POST /languages
  # POST /languages.xml
  def create
    @language = Language.new(params[:language])
    respond_to do |format|
      begin
	      Language.transaction do
	        @label = @language.build_label(params[:label])
	        @label.save!
	        @language.save!
	      end

        flash[:notice] = 'Language was successfully created.'
        format.html { redirect_to languages_url }
        format.xml  { head :created, :location => language_url(@language) }

      rescue ActiveRecord::RecordInvalid => e
        @language.valid?
        @label.valid? # force checking of errors even if  language failed
        format.html { render :action => "new" }
        format.xml  { render :xml => @language.errors.to_xml }
      end
    end
  end

  # PUT /languages/1
  # PUT /languages/1.xml
  def update
    @language = Language.find(params[:id])
    @label = @language.label
    @language.attributes = params[:language]
    @label.attributes = params[:label]

    respond_to do |format|
      if @language.valid? && @label.valid?

        @language.save!
        @label.save!
        flash[:notice] = 'Language was successfully updated.'
        format.html { redirect_to languages_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @language.errors.to_xml }
      end
    end
  end

  # DELETE /languages/1
  # DELETE /languages/1.xml
  def destroy
    @language = Language.find(params[:id])
    @language.destroy

    respond_to do |format|
      format.html { redirect_to languages_url }
      format.xml  { head :ok }
    end
  end
end
