// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function mark_for_destroy(element) {
  if (confirm('This operation will delete this property from all the resources. Are you sure?')){
		$(element).next('.should_destroy').value = 1;
		$(element).up('.dynamic_element').hide();
  }
}