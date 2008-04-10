// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function mark_for_destroy(element) {
  if (confirm('This operation will delete this element from all the resources. Are you sure?')){
		$(element).next('.should_destroy').value = 1;
		$(element).up('.dynamic_element').hide();
  }
}

// Make sure the behaviors still work even after navigating to another page using the ajax navigation.
Event.addBehavior.reassignAfterAjax = true;

// Behaviors

var SpecialPropertyBehavior = Behavior.create({
	onchange : 	function() {
		my_list = this.element.up().next().down('.list_container');
		my_geometry = this.element.up().next().down('.geometry_container');
		switch(this.element.value) {
			case 'List':
				my_geometry.down('.geometry_text').value = "";
				my_list.down('.list_select').selectedIndex = 0;
				new Effect.Fade(my_geometry);
				new Effect.Appear(my_list);
				break;
			case 'File':
				my_list.down('.list_select').value = "";
				my_list.down('.list_select').selectedIndex = 0;
				new Effect.Fade(my_list);
				new Effect.Appear(my_geometry);
				break;
			default:
				my_geometry.down('.geometry_text').value = "";
				my_list.down('.list_select').selectedIndex = 0;
				new Effect.Fade(my_geometry);
				new Effect.Fade(my_list);
		}
	} 
});

/*This will update the hidden input field (in resource editing) which holds the actual value 
to be passed to the model as the checkbox value*/
var CheckboxBehavior = Behavior.create({
	onchange : 	function() {
		if(this.element.checked == true) {
			this.element.next().value = 't';
		}
		else {
			this.element.next().value = 'f';
		}
	} 
});
Event.addBehavior({ 'input.property_checkbox' : CheckboxBehavior });
// Event.addBehavior({ '.select_field_type' : MyBehavior });
// If you need to pass additional values to initialize use:
// Event.addBehavior({ '.select_field_type' : MyBehavior(10, { thing : 15 }) })
// You can also use the attach() method.  If you specify extra arguments to attach they get passed to initialize.
// MyBehavior.attach(el, values, to, init);
// Finally, the rawest method is using the new constructor normally:
// var draggable = new Draggable(element, init, vals);
// Each behaviour has a collection of all its instances in Behavior.instances

Event.addBehavior({

	'#show_all_websites:change' : function() {
		if($F(this) != null) {
			$('website_id').hide();
		}
		else {
			$('website_id').show();
		}
	},
});