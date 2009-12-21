// Create drop zone for tree nodes
// dz_id      - ID of an element (div) to use as a drop zone
// widget_node_id  - ID to return to caller (which object an element was dropped on)
// url        - Url to call in Ajax. receives two parameters:
//                node_id   - ID of a dropped node
//                widget_node_id - ID of a target element (see above)
//                dz_id     - ID of an element (div) to use as a drop zone
function tree_drop_zone(widget_node_id, url, widget, updatable, updatable_view_mode) {
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
    dragData:{
      url:url,
      widget_node_id:widget_node_id,
      widget:widget
    }
  });
  dz.on('beforeload', function(){
    return false;
  });
  dz.on('beforenodedrop', function(dropEvent){
    url = dropEvent.tree.dragData.url;
    node_id = dropEvent.data.node.id;
    widget_node_id = dropEvent.tree.dragData.widget_node_id;
    Ext.Ajax.request({
      url: url,
      method: 'post',
      success: function ( result, request ) {
        Ext.get(updatable).update(result.responseText,true);
      },
      failure: function ( result, request) {
        Ext.MessageBox.alert('Failed', 'You have no permission for this operation!');
      },
      params: {
        'view_mode': updatable_view_mode,
        'options[target_node_id]': node_id,
        'options[widget_node_id]': widget_node_id,
        'options[widget]': widget
      }
    });
  });
}

Ext.Ajax.timeout = 60000;
var tree;

//    Known options:
//    url, tree_label, title, expand_path, resource_type_id,
//    root_id, admin_url, root_title, width
function create_tree(options)
{
  var myTreeLoader = new Ext.tree.TreeLoader({
    dataUrl: options.url,
    baseParams:{
      format:'json',
      view_mode:'json_node',
      'options[widget]':'tree',
      'options[display_hidden]':'t',
      'options[node]':0
    }
  });
  // create the tree
  tree = new Ext.tree.TreePanel({
    loader: myTreeLoader,
    // create initial root node
    root:new Ext.tree.AsyncTreeNode({
      text:options.root_title,
      id:options.root_id,
      loaded:true,
      leaf:false,
      addTarget:options.admin_url,
      cannot_edit:true,
      cannot_edit_delete:true
    }),
    renderTo:options.tree_label,
    title:options.title,
    collapseFirst:true,
    autoHeight:false,
    lines:false,
    useArrows:true,
    width:options.width,
    height:480,
    autoScroll:true,
    enableDD:true,
    animate:true,
    rootVisible:true,
    collapsed:true,
    collapsible:true
  });

  // First time all branch on path was sent, so let's expand it
  tree.expandPath(options.expand_path);
  tree.on('beforenodedrop', function(dropEvent){
    node = dropEvent.dropNode;
    var parentNode = node.parentNode;
    var nodeNextSibling = node.nextSibling;
    var src = node.attributes.id;
    var trg = dropEvent.target.attributes.id;
    if (src == -1) {
      alert("Do not move this node!");
      return false;
    }
    var point = dropEvent.point;
    Ext.Ajax.request({
      url:options.url,
      method: 'post',
      success: function ( result, request ) {
        tree.body.highlight();
      },
      failure: function ( result, request) {
        Ext.MessageBox.alert('Failed', 'You have no permission for this operation!');
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
          text: 'חדש',
          disabled: node.attributes.cannot_create_child,
          href: node.attributes.addTarget +
            encodeURI(
          '&resource[resource_type_id]='+ options.resource_type_id +
            '&resource[tree_node][has_url]=true' +
            '&resource[tree_node][is_main]=true' +
            '&resource[tree_node][parent_id]=' + node.id
        )
        }),
        new Ext.menu.Item({
          text: 'ערוך',
          disabled: node.attributes.cannot_edit,
          href: node.attributes.editTarget
        }),
        new Ext.menu.Item({
          text: 'מחק',
          disabled: node.attributes.cannot_edit_delete,
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
                  params: {
                    'stam': 'delete'
                  }
                });
              }
            }
          )
          }
        }),
        new Ext.menu.Item({
          text: 'פרסם באתר',
          disabled: node.attributes.cannot_edit,
          handler: function(item){handler_func(node, 'publish', 'PUBLISHED')}
        }),
        new Ext.menu.Item({
          text: 'העבר לטיוטה',
          disabled: node.attributes.cannot_edit,
          handler: function(item){handler_func(node, 'draft', 'DRAFT')}
        }),
        new Ext.menu.Item({
          text: 'העבר לארכיון',
          disabled: node.attributes.cannot_edit,
          handler: function(item){handler_func(node, 'archive', 'ARCHIVED')}
        }),
        new Ext.menu.Item({
          text: 'turn mobile on/off',
          disabled: node.attributes.cannot_edit,
          handler: function(item){mobile_handler_func(node)}
        }),
        new Ext.menu.Item({
          text: 'Toggle as first mobile page',
          disabled: node.attributes.cannot_edit || !node.attributes.may_be_mobile_first_page,
          handler: function(item){mobile_first_page_handler_func(node)}
        }),
      ]
    });
    menu.showAt(e.getXY());
  });

  function mobile_first_page_handler_func(node) {
    var is_first_page;
    is_first_page = node.attributes.is_mobile_first_page ? 'unset' : 'set';
    Ext.Msg.confirm('Set as first mobile page',
    'Are you sure you want to ' + is_first_page + ' the page as first mobile one?',
    function(e){
      if(e == 'yes') {
        Ext.Ajax.request({
          url: node.attributes.updateStatus,
          method: 'post',
          params: {
            'set_mobile_first_page': !node.attributes.is_mobile_first_page
          },
          callback: function (options, success, responce){
            if (success) {
              if (node.attributes.is_mobile_first_page) {
                // No switch, just toggle the current node
                node.attributes.is_mobile_first_page ^= true;
                node.setText(node.text.replace(/mobile_first/gi, ""));
                Ext.Msg.alert('Set as first mobile page',
                  'The tree item <' + node.text + '> was successfully unset as first mobile one');
                return true;
              }
              // First we have to unset a prev node
              var root = tree.root;
              root.eachChild(function(node){
                node.setText(node.text.replace(/mobile_first/gi, ""));
                return true;
              });
              // Now we can set a new one
              node.attributes.is_mobile_first_page ^= true;
              if (node.attributes.is_mobile_first_page) {
                node.attributes.is_mobile = true;
                node.text = node.text.replace(/class=\'/, "class='mobile mobile_first ");
                node.setText(node.text);
              }
              Ext.Msg.alert('Set as first mobile page',
              'The tree item <' + node.text + '> was successfully ' + (node.attributes.is_mobile_first_page ? 'set' : 'unset') + ' as first mobile one');
            } else {
              Ext.Msg.alert('Turn mobile ...', 'FAILURE!!!');
            }
          }
        });
      }
    }
  )
  }

  function mobile_handler_func(node) {
    var is_mobile = node.attributes.is_mobile ? 'off' : 'on';
    Ext.Msg.confirm('Turn mobile ' + is_mobile,
    'Are you sure you want to turn mobile ' + is_mobile + '?',
    function(e){
      if(e == 'yes') {
        Ext.Ajax.request({
          url: node.attributes.updateStatus,
          method: 'post',
          params: {
            'set_mobile': 1
          },
          callback: function (options, success, responce){
            if (success) {
              if (node.attributes.is_mobile_first_page) {
                mobile_first_page_handler_func(node);
              }
              node.attributes.is_mobile ^= true;
              if (node.attributes.is_mobile) {
                node.text = node.text.replace(/class=\'/, "class='mobile ");
              } else {
                node.text = node.text.replace(/mobile_first/gi, "");
                node.text = node.text.replace(/mobile/gi, "");
              }
              node.setText(node.text);
              Ext.Msg.alert('Turn mobile ...',
              'The tree item <' + node.text + '> was successfully turned ' + (node.attributes.is_mobile ? 'on' : 'off'));
            } else {
              Ext.Msg.alert('Turn mobile ...', 'FAILURE!!!');
            }
          }
        });
      }
    }
  )
  }

  function handler_func(node, klass, status) {
    Ext.Msg.confirm('Tree item to ' + klass, 'Are you sure you want to turn ' + node.text + ' to ' + klass + '?',
    function(e){
      if(e == 'yes') {
        Ext.Ajax.request({
          url: node.attributes.updateStatus,
          method: 'post',
          params: {
            'status': status
          },
          callback: function (options, success, responce){
            if (success) {
              node.setText("<span class='" + klass + "'>" + node.attributes.resource_name + "</span>");
              Ext.Msg.alert('Tree item to ' + klass, 'The tree item <' + node.text + '> was successfully turned to ' + klass);
            } else {
              Ext.Msg.alert('Tree item to ' + klass, 'FAILURE!!!');
            }
          }
        });
      }
    }
  )
  }

}
