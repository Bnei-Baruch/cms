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
        Ext.MessageBox.alert('Failed', 'You have no permission for this operation!'); },
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

function create_simple_tree(url, children, tree_label, title)
{
  Ext.tree.WrapNodeUI = Ext.extend(Ext.tree.TreeNodeUI, {
    //focus: Ext.emptyFn, // prevent odd scrolling behavior

    renderElements : function(n, a, targetNode, bulkRender){
      // add some indent caching, this helps performance when rendering a large tree
      this.indentMarkup = n.parentNode ? n.parentNode.ui.getChildIndent() : '';

      var href = a.href ? a.href : Ext.isGecko ? "" : "#";
      var buf = ['<li class="x-tree-node"><div ext:tree-node-id="',n.id,'" class="x-tree-node-el x-tree-node-leaf x-unselectable ', a.cls,'" unselectable="on">',
        '<span class="x-tree-node-indent">',this.indentMarkup,"</span>",
        '<img src="', this.emptyIcon, '" class="x-tree-ec-icon x-tree-elbow" />',
        '<img src="', a.icon || this.emptyIcon, '" class="x-tree-node-icon',(a.icon ? " x-tree-node-inline-icon" : ""),(a.iconCls ? " "+a.iconCls : ""),'" unselectable="on" />',
        '<a hidefocus="on" class="x-tree-node-anchor" href="',href,'" tabIndex="1" ',
        a.hrefTarget ? ' target="'+a.hrefTarget+'"' : "", '><span unselectable="on">',n.text,"</span></a>",
        '</div>',
        '<ul class="x-tree-node-ct" style="display:none;"></ul>',
        "</li>"].join('');

      var nel;
      if(bulkRender !== true && n.nextSibling && (nel = n.nextSibling.ui.getEl())){
        this.wrap = Ext.DomHelper.insertHtml("beforeBegin", nel, buf);
      }else{
        this.wrap = Ext.DomHelper.insertHtml("beforeEnd", targetNode, buf);
      }
        
      this.elNode = this.wrap.childNodes[0];
      this.ctNode = this.wrap.childNodes[1];
      var cs = this.elNode.childNodes;
      this.indentNode = cs[0];
      this.ecNode = cs[1];
      this.iconNode = cs[2];
      this.anchor = cs[3];
      this.textNode = cs[3].firstChild;
    }
  });
  
  // create the tree
  tree = new Ext.tree.TreePanel({
    loader: new Ext.tree.TreeLoader({
      url: url,
      requestMethod:'GET',
      uiProviders:{
        'wrap': Ext.tree.WrapNodeUI
      },
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
    header:false,
    autoHeight:true,
    lines:false,
    useArrows:true,
    width:210,
    animate:true,
    rootVisible:false
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
          href: node.attributes.addTarget + '?' +
            encodeURI(
          'resource[resource_type_id]='+ resource_type_id +
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