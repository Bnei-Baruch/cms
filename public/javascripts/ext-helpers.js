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
        dragData:{url:url,widget_node_id:widget_node_id,widget:widget}
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

function create_tree(url, children, tree_label, title, expand_path, resource_type_id)
{
    var myTreeLoader = new Ext.tree.TreeLoader({
        dataUrl: url,
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
            text: 'Invisible Root',
            id:'0',
            loaded:true,
            leaf:false,
            children:children
        }),
        renderTo:tree_label,
        title: title,
        collapseFirst:true,
        autoHeight:false,
        lines:false,
        useArrows:true,
        width:300,
        height:480,
        autoScroll:true,
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
                    href: node.attributes.addTarget +
                        encodeURI(
                        '&resource[resource_type_id]='+ resource_type_id +
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