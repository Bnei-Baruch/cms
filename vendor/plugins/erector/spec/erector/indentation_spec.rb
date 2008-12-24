require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe "indentation" do

  it "can detect newliney tags" do
    widget = ::Erector::Widget.new
    string = widget.output
    widget.enable_prettyprint = true
    widget.newliney("i").should == false
    widget.newliney("table").should == true
  end

  it "should not add newline for non-newliney tags" do
    Erector::Widget.new() do
      text "Hello, "
      b "World"
    end.enable_prettyprint(true).to_s.should == "Hello, <b>World</b>"
  end
  
  it "should add newlines before open newliney tags" do
    Erector::Widget.new() do
      p "foo"
      p "bar"
    end.enable_prettyprint(true).to_s.should == "<p>foo</p>\n<p>bar</p>\n"
  end
  
  it "should add newlines between text and open newliney tag" do
    Erector::Widget.new() do
      text "One"
      p "Two"
    end.enable_prettyprint(true).to_s.should == "One\n<p>Two</p>\n"
  end
  
  it "should add newlines after end newliney tags" do
    Erector::Widget.new() do
      tr do
        td "cell"
      end
    end.enable_prettyprint(true).to_s.should == "<tr>\n  <td>cell</td>\n</tr>\n"
  end
  
  it "should treat empty elements as start and end" do
    Erector::Widget.new() do
      p "before"
      br
      p "after"
    end.enable_prettyprint(true).to_s.should == "<p>before</p>\n<br />\n<p>after</p>\n"
  end
  
  it "empty elements sets at_start_of_line" do
    Erector::Widget.new() do
      text "before"
      br
      p "after"
    end.enable_prettyprint(true).to_s.should == "before\n<br />\n<p>after</p>\n"
  end

  it "will not insert extra space before/after input element" do
    # If dim memory serves, the reason for not adding spaces here is
    # because it affects/affected the rendering in browsers.
    Erector::Widget.new() do
      text 'Name'
      input :type => 'text'
      text 'after'
    end.enable_prettyprint(true).to_s.should == 'Name<input type="text" />after'
  end
  
  it "will indent" do
    Erector::Widget.new() do
      html do
        head do
          title "hi"
        end
        body do
          div do
            p "paragraph"
          end
        end
      end
    end.enable_prettyprint(true).to_s.should == <<END
<html>
  <head>
    <title>hi</title>
  </head>
  <body>
    <div>
      <p>paragraph</p>
    </div>
  </body>
</html>
END
  end
  
  it "can turn off newlines" do
    Erector::Widget.new() do
      text "One"
      p "Two"
    end.enable_prettyprint(false).to_s.should == "One<p>Two</p>"
  end
  
  it "cannot turn newlines on and off, because the output is cached" do
    widget = Erector::Widget.new() do
      text "One"
      p "Two"
    end.enable_prettyprint(false)
    widget.to_s.should == "One<p>Two</p>"
    widget.enable_prettyprint(true)
    widget.to_s.should == "One<p>Two</p>"
    widget.enable_prettyprint(false)
    widget.to_s.should == "One<p>Two</p>"
  end
  
  it "can turn on newlines via to_pretty" do
    widget = Erector::Widget.new() do
      text "One"
      p "Two"
    end.enable_prettyprint(false).to_pretty.should == "One\n<p>Two</p>\n"
  end
  
  it "to_pretty will leave newlines on if they already were" do
    widget = Erector::Widget.new() do
      text "One"
      p "Two"
    end.enable_prettyprint(true).to_pretty.should == "One\n<p>Two</p>\n"
  end
  
  it "can turn newlines on/off via global variable" do
    Erector::Widget.new { br }.to_s.should == "<br />"
    Erector::Widget.prettyprint_default = true
    Erector::Widget.new { br }.to_s.should == "<br />\n"
    Erector::Widget.prettyprint_default = false
    Erector::Widget.new { br }.to_s.should == "<br />"
  end
  
end

