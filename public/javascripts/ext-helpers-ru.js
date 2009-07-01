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
            text: 'брось сюда',
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
                Ext.MessageBox.alert('неудача', 'У Вас нет разрешения на выполнение этой операции!');
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

function create_tree(url, tree_label, title, expand_path, resource_type_id, root_id, admin_url, root_title, width)
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
            text: root_title,
            id:root_id,
            loaded:true,
            leaf:false,
            addTarget:admin_url,
            cannot_edit:true,
            cannot_edit_delete:true
        }),
        renderTo:tree_label,
        title: title,
        collapseFirst:true,
        autoHeight:false,
        lines:false,
        useArrows:true,
        width:width,
        height:480,
        autoScroll:true,
        enableDD:true,
        animate:true,
        rootVisible:true,
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
                Ext.MessageBox.alert('неудача', 'У Вас нет разрешения на выполнение этой операции!');
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
                    text: 'новый',
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
                    text: 'редактировать',
                    disabled: node.attributes.cannot_edit,
                    href: node.attributes.editTarget
                }),
                new Ext.menu.Item({
                    text: 'удалить',
                    disabled: node.attributes.cannot_edit_delete,
                    handler: function (item) {
                        Ext.Msg.confirm('Удаление страницы', 'Вы уверены, что хотите удалить <' + node.text + '>?',
                        function(e){
                            if(e == 'yes') {
                                Ext.Ajax.request({
                                    url: node.attributes.delTarget,
                                    method: 'post',
                                    callback: function (options, success, responce){
                                        if (success) {
                                            Ext.Msg.alert('Удаление страницы', 'Страница <' + node.text + '> успешно удалена');
                                            node.remove();
                                        } else {
                                            Ext.Msg.alert('Удаление страницы', 'НЕУДАЧА!!!');
                                        }
                                    },
                                    params: { 'stam': 'delete' }
                                });
                            }
                        }
                    )
                    }
                }),
                new Ext.menu.Item({
                    text: 'опубликовать',
                    disabled: node.attributes.cannot_edit,
                    handler: function (item) {
                        Ext.Msg.confirm('Публикация страницы', 'Вы уверены, что хотите опубликовать <' + node.text + '>?',
                        function(e){
                            if(e == 'yes') {
                                Ext.Ajax.request({
                                    url: node.attributes.updateStatus,
                                    method: 'post',
                                    params: {'status': 'PUBLISHED'},
                                    callback: function (options, success, responce){
                                        if (success) {
                                            node.setText(node.attributes.resource_name);
                                            Ext.Msg.alert('Публикация страницы', 'Страница <' + node.text + '> успешно опубликована');
                                        } else {
                                            Ext.Msg.alert('Публикация страницы', 'НЕУДАЧА!!!');
                                        }
                                    }
                                });
                            }
                        }
                    )
                    }
                }),  
                new Ext.menu.Item({
                    text: 'черновик',
                    disabled: node.attributes.cannot_edit,
                    handler: function (item) {
                        Ext.Msg.confirm('Черновик', 'Вы уверены, что хотите сделать черновиком <' + node.text + '>?',
                        function(e){
                            if(e == 'yes') {
                                Ext.Ajax.request({
                                    url: node.attributes.updateStatus,
                                    method: 'post',
                                    params: {'status': 'DRAFT'},
                                    callback: function (options, success, responce){
                                        if (success) {
                                            node.setText("<span class='draft'>" + node.attributes.resource_name + "</span>");
                                            Ext.Msg.alert('Черновик', 'Страница <' + node.text + '> преобразована в черновик');
                                        } else {
                                            Ext.Msg.alert('Черновик', 'НЕУДАЧА!!!');
                                        }
                                    }
                                });
                            }
                        }
                    )
                    }
                }), 
                new Ext.menu.Item({
                    text: 'архив',
                    disabled: node.attributes.cannot_edit,
                    handler: function (item) {
                        Ext.Msg.confirm('Архивация страницы', 'Вы уверены, что хотите заархивировать <' + node.text + '>?',
                        function(e){
                            if(e == 'yes') {
                                Ext.Ajax.request({
                                    url: node.attributes.updateStatus,
                                    method: 'post',
                                    params: {'status': 'ARCHIVED'},
                                    callback: function (options, success, responce){
                                        if (success) {
                                            node.setText("<span class='archived'>" + node.attributes.resource_name + "</span>");
                                            Ext.Msg.alert('Архивация страницы', 'Страница <' + node.text + '> заархивирована');
                                        } else {
                                            Ext.Msg.alert('Архивация страницы', 'НЕУДАЧА!!!');
                                        }
                                    }
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
