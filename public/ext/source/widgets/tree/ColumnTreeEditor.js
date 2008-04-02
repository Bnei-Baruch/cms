Ext.tree.ColumnTreeEditor = function(tree, config)
{
	config = config || {};
	var field = config.events ? config : new Ext.form.TextField(config);	
	Ext.tree.ColumnTreeEditor.superclass.constructor.call(this, field);
	
	this.activeEditor = null;
	
	this.addEvents({
		"beforeedit" : true
	});
	
	this.tree = tree;
	if(!this.tree.readOnly)
	{
		tree.on('beforeclick', this.beforeNodeClick, this);
		tree.on('expand', this.afterNodeExpand, this);
		this.on('complete', this.updateNode, this);
		this.on('specialkey', this.onSpecialKey, this);
	}
}
Ext.extend(Ext.tree.ColumnTreeEditor, Ext.Editor, {
	/**
     * @cfg {String} alignment
     * The position to align to (see {@link Ext.Element#alignTo} for more details, defaults to "l-l").
     */
    alignment: "tl-tl",
    // inherit
    autoSize: false,
    /**
     * @cfg {Boolean} hideEl
     * True to hide the bound element while the editor is displayed (defaults to false)
     */
    hideEl : false,
    /**
     * @cfg {String} cls
     * CSS class to apply to the editor (defaults to "x-small-editor x-tree-editor")
     */
    cls: "x-small-editor x-tree-editor",
    /**
     * @cfg {Boolean} shim
     * True to shim the editor if selects/iframes could be displayed beneath it (defaults to false)
     */
    shim:false,
    // inherit
    shadow:"frame",
    /**
     * @cfg {Number} maxWidth
     * The maximum width in pixels of the editor field (defaults to 250).  Note that if the maxWidth would exceed
     * the containing tree element's size, it will be automatically limited for you to the container width, taking
     * scroll and client offsets into account prior to each edit.
     */
    maxWidth: 250,
    
    afterNodeExpand : function(node)
    {
    	if(this.tree.colModel)
    	{
    		cols = this.tree.colModel.config;
	    	editor = this;
	    	colModel = this.tree.colModel;
			node.eachChild(function(node)
	    	{
				for(i=1; i<cols.length; i++)
				{
					cell = Ext.get('x-tree-cell-'+node.id+'-'+i);
					cell.col = i;
					cell.colModel = colModel;
					if(cell)
					{
						cell.on('click', function(){
							var cell = this;
							if(cell.colModel.config[cell.col].editOnlyLeaf)
							{
								if(node.isLeaf())
								{
									editor.startCellEdit(this, node);
								}
							}
							else
							{
								editor.startCellEdit(this, node);
							}
						});
					}
				}
			});
    	}
    },
    
    // private
    triggerEdit : function(node)
    {
        this.completeEdit();
        this.editNode = node;
        this.startEdit(node.ui.textNode, node.text);
    },
    
    // private
    beforeNodeClick : function(node, e)
    {
        if(this.tree.getSelectionModel().isSelected(node)){
            e.stopEvent();
            this.triggerEdit(node);
            return false;
        }
    },
    
    // private
    updateNode : function(ed, value)
    {
        this.tree.getTreeEl().un('scroll', this.cancelEdit, this);
        this.editNode.setText(value);
    },
    
    // private
    onSpecialKey : function(field, e)
    {
        var k = e.getKey();
        if(k == e.ESC){
            e.stopEvent();
            this.cancelEdit();
        }else if(k == e.ENTER && !e.hasModifier()){
            e.stopEvent();
            this.completeEdit();
        }
    },
    
    startCellEdit : function(cell, node)
    {
    	if(cell.colModel.isCellEditable(cell.col))
    	{
    		var dataIndex = cell.colModel.getDataIndex(cell.col);
    		this.boundEl = cell;
    		
    		var v = node.attributes[dataIndex] !== undefined ? node.attributes[dataIndex] : this.boundEl.dom.innerHTML;
    		var e = {
    			dataIndex: dataIndex,
    			value: v,
    			column: cell.col,
    		};
    		if(this.fireEvent("beforeedit", e) !== false && !e.cancel)
    		{
    			var ed = cell.colModel.getCellEditor(cell.col);
    			if(!ed.rendered)
    			{
    				ed.render(ed.parentEl || document.body);
    				if(ed.autoSize)
    				{
    					var sz = this.boundEl.getSize();
    					switch(ed.autoSize)
    					{
    						case "width":
    							ed.setSize(sz.width, "");
    							break;
    						case "height":
    							ed.setSize("", sz.height);
    							break;
    						default:
    							ed.setSize(sz.width, sz.height);
    					}
    				}    				
    			}
    			ed.el.alignTo(this.boundEl, this.alignment);
    			this.activeEditor = ed;
    			this.editing = true;
    			this.editNode = node;
    			this.dataIndex = dataIndex;
    			ed.on("specialkey", this.onCellEditorKey, this);
    			ed.on("complete", this.onCellEditComplete, this);
    			ed.on("complete", function(){
    				if(op = cell.colModel.config[cell.col].operator)
	    			{
	    				this.initOperator(op, this.editNode, cell);
	    			}
    			}, this);
    			
    			ed.startEdit(this.boundEl, node.attributes[dataIndex]);
    		}
    		
    	}
    },
    
    onCellEditorKey : function(field, e)
    {
    	var k = e.getKey(), ed = this.activeEditor;
        if(k == e.ESC){
            ed.cancelEdit();
        }else if(k == e.ENTER && !e.hasModifier()){
        	ed.completeEdit();
            e.stopEvent();
        }
    },
    
    onCellEditComplete : function()
    {
    	var val = this.activeEditor.field.getValue();
    	
    	/**
    	 * Kinda sloppy to have to update the model and display separately
    	 * but there is no handle to render just a node.  Also, it saves processing
    	 * time to just do it here.
    	 */
    	
    	//update the node attribute with the new value
    	this.editNode.attributes[this.dataIndex] = val;
    	// if the value is an empty string put for nbsp html formatting
    	if(val == '')
    	{
    		val = '&nbsp';
    	}
    	
    	//Upon cell edit completion update the value to the div inside of the cell
    	this.boundEl.child('div.x-tree-col-text').update(val);
    	if(this.editing)
    	{
    		this.fireEvent("complete", this, this.editNode.text, this.startValue);
    		this.editing = false;
    	}
    },
    
    /****
     * initOperator applies the passed function or reserved function to all parent cells in
     * the columnTree.  For example, if you call the add function on the leafs of a tree, the
     * sum of all the leaves will be the value of the immediate parent.  This will bubble up to 
     * the root
     */
    initOperator : function(_op, _editNode, _cell)
    {
    	var fn;
    	switch(_op)
    	{
    		case "add":
    			fn = this.sum;
    			break;
    		default:
    			fn = _op;
    	}
    	//pass null for the scope in order to get the current node
    	_editNode.bubble(fn, null, [_cell, _editNode]);
    },
    
    sum : function(params)
    {
    	var cell = params[0];
    	var editNode = params[1];
    	var node = this;
    	
    	var dataIndex = cell.colModel.getDataIndex(cell.col);
    	
    	//sum the children for all parent nodes of the current node
    	if(node != editNode)
    	{
    		var children = node.childNodes;
    		var total = 0;
    		for(var i = 0, len = children.length; i < len; i++) 
    		{
    			total = total + Number(children[i].attributes[dataIndex]);
    		}
    		node.attributes[dataIndex] = total;
    		
    		if(currentCell = Ext.get('x-tree-cell-'+node.id+'-'+cell.col))
    		{
    			currentCell.child('div.x-tree-col-text').update(total);
    		}
    	}
    }
});