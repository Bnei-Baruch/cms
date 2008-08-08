// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function mark_for_destroy(element) {
    if (confirm('This operation will delete this element from all the resources. Are you sure?')){
        $(element).siblings('.should_destroy').val('1');
        $(element).parents('.dynamic_element').hide();
    }
}

/*This will update the hidden input field (in resource editing) which holds the actual value 
to be passed to the model as the checkbox value*/
var CheckboxBehavior = function() {
    var val = $(this).next().val();
    $(this).next().val(val == 't' ? 'f' : 't');
};
$(function() {
    $('input.property_checkbox').click(CheckboxBehavior);
});

var SpecialPropertyBehavior = function(){
    var value = $(this).val();
    var my_list = $(this).parent().next().children('.list_container');
    var my_geometry = $(this).parent().next().children('.geometry_container');
    switch(value){
        case 'List':
            my_geometry.fadeOut('slow', function(){
              $(this).children('.geometry_text').text('');
            });
            my_list.fadeIn('slow', function(){
              $(this).children('.list_select').val('selectedIndex', 0);
            });
            break;
        case 'File':
            my_geometry.fadeIn('slow', function(){
              $(this).children('.geometry_text').text('');
            });
            my_list.fadeOut('slow', function(){
              $(this).children('.list_select').val('selectedIndex', 0);
            });
            break;
        default:
            my_geometry.fadeOut('slow', function(){
              $(this).children('.geometry_text').text('');
            });
            my_list.fadeOut('slow', function(){
              $(this).children('.list_select').val('selectedIndex', 0);
            });
    }
};

//Event.addBehavior({
//
//	'#show_all_websites:change' : function() {
//		if($F(this) != null) {
//			$('website_id').hide();
//		}
//		else {
//			$('website_id').show();
//		}
//	}
//});

