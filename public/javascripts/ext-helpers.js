// Create drop zone for tree nodes
// dz_id      - ID of an element (div) to use as a drop zone
// widget_node_id  - ID to return to caller (which object an element was dropped on)
// url        - Url to call in Ajax. receives two parameters:
//                node_id   - ID of a dropped node
//                widget_node_id - ID of a target element (see above)
//                dz_id     - ID of an element (div) to use as a drop zone
function tree_drop_zone(widget_node_id, url, widget, updatable) {
  dz = new Ext.tree.TreePanel({
    renderTo:'dz-' + widget_node_id,
    animate:true,
    autoScroll:true,
    root: new Ext.tree.AsyncTreeNode({
      text: 'Drop here',
      draggable:false,
      id:'target_' + widget_node_id
    }),
    rootVisible: true,
    autoHeight:true,
    autoWidth:false,
    lines:false,
    collapseFirst:true,
    loader: new Ext.tree.TreeLoader({
    }),
    containerScroll:false,
    enableDD:true,
    dragData:{url:url,widget_node_id:widget_node_id,widget:widget}
  });
  dz.on('beforenodedrop', function(dropEvent){
    url = dropEvent.tree.dragData.url;
    node_id = dropEvent.data.node.id;
    widget_node_id = dropEvent.tree.dragData.widget_node_id;
    // Ext.Ajax.defaultPostHeader = ‘application/json’;
    // Ext.Ajax.defaultHeaders = {
    // 'Content-Type': 'application/xml; charset=utf-8'
    // };
    Ext.Ajax.request({
      url: url,
      method: 'post',
      success: function ( result, request ) { 
        // Ext.MessageBox.alert('Success', result);
		// return;
		// Ext.get(dz_id).dom
		Ext.get(updatable).update(result.responseText,true);
		// Ext.get(dz_id).parent().replaceClass('');
		
	  },
      failure: function ( result, request) { 
        Ext.MessageBox.alert('Failed', 'not good'); },
      // headers: {
      // 	'Content-Type': 'application/json; charset=utf-8'
      // },
      params: {
		'view_mode': 'preview_update',
        'options[target_node_id]': node_id,
        'options[widget_node_id]': widget_node_id,
        'options[widget]': widget
      }
    });
  });
}

function create_tree(url, children, tree_label, title, expand_path, resource_type_id)
{
  // create the tree
  tree = new Ext.tree.TreePanel({
    loader: new Ext.tree.TreeLoader({
      url: url,
      requestMethod:'GET',
      baseParams:{format:'json',
        widget:'tree',
        view_mode:'json_node',
        display_hidden:'t'
      }
    }),
    // create initial root node
    root:new Ext.tree.AsyncTreeNode({
      text: 'Invisible Root',
      id:'0',
      loaded:true,
      leaf:false,
      children:children
    }),
    renderTo:tree_label,
    title: title,
    collapseFirst:true,
    autoHeight:true,
    lines:false,
    useArrows:true,
    width:180,
    enableDD:true,
    animate:true,
    rootVisible:false,
    collapsed:true,
    collapsible:true
  });
  // First time all branch on path was sent, so let's expand it
  tree.expandPath(expand_path);  
  tree.on('beforenodedrop', function(dropEvent){ 
	node = dropEvent.dropNode;
	var parentNode = node.parentNode;
	var nodeNextSibling = node.nextSibling;
	var src = node.attributes.id;
	var trg = dropEvent.target.attributes.id;
	var point = dropEvent.point;  
	Ext.Ajax.request({
      url: url,
      method: 'post',
      success: function ( result, request ) {
		tree.body.highlight();
	  },
      failure: function ( result, request) { 
        Ext.MessageBox.alert('Failed', 'not good');
		parentNode.insertBefore(node, nodeNextSibling);
	  },
      params: {
		'view_mode': 'tree_nodes_exchange',
        'options[target_node_id]': trg,
        'options[source_node_id]': src,
        'options[point]': point,
        'options[widget]': 'tree'
      }
    });
  });
  tree.on('contextmenu', function(node, e){
    var menu = new Ext.menu.Menu({
      items: [
        new Ext.menu.Item({
          text: 'New',
          disabled: node.attributes.cannot_create_child,
          href: node.attributes.addTarget + '?' +
            encodeURI(
          'resource[resource_type_id]='+ resource_type_id +
            '&resource[tree_node][has_url]=true' +
            '&resource[tree_node][is_main]=true' +
            '&resource[tree_node][parent_id]=' + node.id
        )
        }),
        new Ext.menu.Item({
          text: 'Edit',
          disabled: node.attributes.cannot_edit,
          href: node.attributes.editTarget
        }),
        new Ext.menu.Item({
          text: 'Delete',
          disabled: node.attributes.cannot_delete,
          handler: function (item) {
            Ext.Msg.confirm('Tree item Deletion', 'Are you sure you want to delete ' + node.text + '?',
            function(e){
              if(e == 'yes') {
                Ext.Ajax.request({
                  url: node.attributes.delTarget,
                  method: 'post',
                  callback: function (options, success, responce){
                    if (success) {
                      Ext.Msg.alert('Tree item Deletion', 'The tree item <' + node.text + '> was successfully deleted');
                      node.remove();
                    } else {
                      Ext.Msg.alert('Tree item Deletion', 'FAILURE!!!');
                    }
                  },
                  params: { '_method': 'delete' }
                });
              }
            }
          )
          }
        }),
      ]
    });
    menu.showAt(e.getXY());
  });



}