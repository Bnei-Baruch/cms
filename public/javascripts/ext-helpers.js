// Create drop zone for tree nodes
// dz_id      - ID of an element (div) to use as a drop zone
// widget_node_id  - ID to return to caller (which object an element was dropped on)
// url        - Url to call in Ajax. receives two parameters:
//                node_id   - ID of a dropped node
//                widget_node_id - ID of a target element (see above)
//                dz_id     - ID of an element (div) to use as a drop zone
function tree_drop_zone(dz_id, widget_node_id, url) {
  dz = new Ext.tree.TreePanel({
    renderTo:dz_id,
    animate:true,
    autoScroll:true,
    root: new Ext.tree.AsyncTreeNode({
      text: 'Drop here',
      draggable:false,
      id:'target_'+dz_id
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
    dragData:{url:url,widget_node_id:widget_node_id,dz_id:dz_id}
  });
    dz.on('beforenodedrop', function(dropEvent){
      url = dropEvent.tree.dragData.url;
      node_id = dropEvent.data.node.id;
      widget_node_id = dropEvent.tree.dragData.widget_node_id;
      dz_id = dropEvent.tree.dragData.dz_id;
      // Ext.Ajax.defaultPostHeader = ‘application/json’;
      // Ext.Ajax.defaultHeaders = {
      // 'Content-Type': 'application/xml; charset=utf-8'
      // };
      Ext.Ajax.request({
        url: url,
        method: 'post',
        success: function ( result, request ) { 
          Ext.MessageBox.alert('Success', 'good');},
        failure: function ( result, request) { 
          Ext.MessageBox.alert('Failed', 'not good'); },
        // headers: {
        // 	'Content-Type': 'application/json; charset=utf-8'
        // },
        params: {
          'node_id': node_id,
          'widget_node_id': widget_node_id,
          'dz_id': dz_id
        }
      });
    });
  }
