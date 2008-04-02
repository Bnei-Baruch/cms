Ext.tree.ColumnModel = function(config){
	/**
     * The config passed into the constructor
     */
    this.config = config;
	this.lookup = {};
	
	// if no id, create one
    // if the column does not have a dataIndex mapping,
    // map it to the order it is in the config
    for(var i = 0, len = config.length; i < len; i++){
        var c = config[i];
        if(typeof c.dataIndex == "undefined"){
            c.dataIndex = i;
        }
        if(typeof c.renderer == "string"){
            c.renderer = Ext.util.Format[c.renderer];
        }
        if(typeof c.id == "undefined"){
            c.id = i;
        }
        if(c.editor && c.editor.isFormField){
            c.editor = new Ext.tree.ColumnTreeEditor(c.editor);
        }
        this.lookup[c.id] = c;
    }
    
    /**
     * The width of columns which have no width specified (defaults to 100)
     * @type Number
     */
    this.defaultWidth = 100;
    
	this.addEvents({
        /**
	     * @event widthchange
	     * Fires when the width of a column changes.
	     * @param {ColumnModel} this
	     * @param {Number} columnIndex The column index
	     * @param {Number} newWidth The new width
	     */
	    "widthchange": true,
    });
    Ext.tree.ColumnModel.superclass.constructor.call(this);
};

Ext.extend(Ext.tree.ColumnModel, Ext.util.Observable, {
	/**
	 * Returns the id of the column at the specified index.
     * @param {Number} index The column index
     * @return {String} the id
	 */
	getColumnId : function(index){
        return this.config[index].id;
    },
	/**
     * Returns the column for a specified id.
     * @param {String} id The column id
     * @return {Object} the column
     */
    getColumnById : function(id){
        return this.lookup[id];
    },
    
    /**
     * Returns the index for a specified column id.
     * @param {String} id The column id
     * @return {Number} the index, or -1 if not found
     */
    getIndexById : function(id){
        for(var i = 0, len = this.config.length; i < len; i++){
            if(this.config[i].id == id){
                return i;
            }
        }
        return -1;
    },
    
    /**
     * Returns the number of columns.
     * @return {Number}
     */
    getColumnCount : function(visibleOnly){
        if(visibleOnly === true){
            var c = 0;
            for(var i = 0, len = this.config.length; i < len; i++){
                if(!this.isHidden(i)){
                    c++;
                }
            }
            return c;
        }
        return this.config.length;
    },
    
    /**
     * Returns the column configs that return true by the passed function that is called with (columnConfig, index)
     * @param {Function} fn
     * @param {Object} scope (optional)
     * @return {Array} result
     */
    getColumnsBy : function(fn, scope){
        var r = [];
        for(var i = 0, len = this.config.length; i < len; i++){
            var c = this.config[i];
            if(fn.call(scope||this, c, i) === true){
                r[r.length] = c;
            }
        }
        return r;
    },
    
	/**
     * Returns the rendering (formatting) function defined for the column.
     * @param {Number} col The column index.
     * @return {Function} The function used to render the cell. See {@link #setRenderer}.
     */
    getRenderer : function(col){
        if(!this.config[col].renderer){
            return Ext.tree.ColumnModel.defaultRenderer;
        }
        return this.config[col].renderer;
    },
    
    /**
     * Sets the rendering (formatting) function for a column.
     * @param {Number} col The column index
     * @param {Function} fn The function to use to process the cell's raw data
     * to return HTML markup for the tree view. The render function is called with
     * the following parameters:<ul>
     * <li>Data value.</li>
     * <li>Cell metadata. An object in which you may set the following attributes:<ul>
     * <li>css A CSS style string to apply to the table cell.</li>
     * <li>attr An HTML attribute definition string to apply to the data container element <i>within</i> the table cell.</li></ul>
     * <li>The {@link Ext.data.Record} from which the data was extracted.</li>
     * <li>Row index</li>
     * <li>Column index</li>
     * <li>The {@link Ext.data.Store} object from which the Record was extracted</li></ul>
     */
    setRenderer : function(col, fn){
        this.config[col].renderer = fn;
    },

    /**
     * Returns the width for the specified column.
     * @param {Number} col The column index
     * @return {Number}
     */
    getColumnWidth : function(col){
        return this.config[col].width || this.defaultWidth;
    },
    
	/**
     * Sets the width for a column.
     * @param {Number} col The column index
     * @param {Number} width The new width
     */
    setColumnWidth : function(col, width, suppressEvent){
        this.config[col].width = width;
        this.totalWidth = null;
        if(!suppressEvent){
             this.fireEvent("widthchange", this, col, width);
        }
    },
    
    /**
     * Returns the tooltip for the specified column.
     * @param {Number} col The column index
     * @return {String}
     */
    getColumnTooltip : function(col){
            return this.config[col].tooltip;
    },
    /**
     * Sets the tooltip for a column.
     * @param {Number} col The column index
     * @param {String} tooltip The new tooltip
     */
    setColumnTooltip : function(col, tooltip){
            this.config[col].tooltip = tooltip;
    },
    
    /**
     * Returns the dataIndex for the specified column.
     * @param {Number} col The column index
     * @return {Number}
     */
    getDataIndex : function(col){
        return this.config[col].dataIndex;
    },
    
	/**
     * Sets the dataIndex for a column.
     * @param {Number} col The column index
     * @param {Number} dataIndex The new dataIndex
     */
    setDataIndex : function(col, dataIndex){
        this.config[col].dataIndex = dataIndex;
    },
	
	/**
     * Returns the columnIndex for the specified dataIndex.
     * @param {Number} dataIndex The new dataIndex
     * @return {Object} the column
     */
	findColumnIndex : function(dataIndex){
        var c = this.config;
        for(var i = 0, len = c.length; i < len; i++){
            if(c[i].dataIndex == dataIndex){
                return i;
            }
        }
        return -1;
    },
    
    /**
     * Returns true if the cell is editable.
     * @param {Number} colIndex The column index
     * @param {Number} rowIndex The row index
     * @return {Boolean}
     */
    isCellEditable : function(colIndex, rowIndex){
        return (this.config[colIndex].editable || (typeof this.config[colIndex].editable == "undefined" && this.config[colIndex].editor)) ? true : false;
    },

    /**
     * Returns the editor defined for the cell/column.
     * @param {Number} colIndex The column index
     * @param {Number} rowIndex The row index
     * @return {Object}
     */
    getCellEditor : function(colIndex, rowIndex){
        return this.config[colIndex].editor;
    },

    /**
     * Sets if a column is editable.
     * @param {Number} col The column index
     * @param {Boolean} editable True if the column is editable
     */
    setEditable : function(col, editable){
        this.config[col].editable = editable;
    },
    
	/**
     * Sets the editor for a column.
     * @param {Number} col The column index
     * @param {Object} editor The editor object
     */
    setEditor : function(col, editor){
        this.config[col].editor = editor;
    }
	
});

Ext.tree.ColumnModel.defaultRenderer = function(value){
	if(typeof value == "string" && value.length < 1){
	    return "*";
	}
	return value;
};