// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function mark_for_destroy(element) {
  if (confirm('This operation will delete this property from all the resources. Are you sure?')){
		$(element).next('.should_destroy').value = 1;
		$(element).up('.dynamic_element').hide();
  }
}

// Make sure the behaviors still work even after navigating to another page using the ajax navigation.
Event.addBehavior.reassignAfterAjax = true;

// Behaviors
Event.addBehavior({

'#show_all_websites:change' : function() {
	if($F(this) != null) {
		$('website_id').hide();
	}
	else {
		$('website_id').show();
	}
    ;
}
});