package ig.imgui;

import ig.utils.MathUtils;

enum Alignment {
    LEFT;
    TOP;
    RIGHT;
    BOTTOM;
    CENTER;
}

class BoxAttrs {
    public var padding       : Int;
    public var padding_left  : Int;
    public var padding_top   : Int;
    public var padding_right : Int;
    public var padding_bottom : Int;

    public var margin       : Int;
    public var margin_left  : Int;
    public var margin_top   : Int;
    public var margin_right : Int;
    public var margin_bottom : Int;

    public var border       : Int;
    public var border_left  : Int;
    public var border_top   : Int;
    public var border_right : Int;
    public var border_bottom : Int;

    public var align : Alignment;

    public var width : Int;
    public var height : Int;
    public var default_width : Bool;
    public var default_height : Bool;

    public var stretch_horizontal : Float;
    public var stretch_vertical   : Float;

    public function new( attrs:Dynamic ) {
        this.convertFrom(attrs);
    }

    private function convertFrom( attrs:Dynamic ) {
        align = Reflect.field( attrs, "align" );
        if (align == null) {
            align = Alignment.LEFT;
        }

        padding        = Reflect.field( attrs, "padding"        );
        padding_left   = Reflect.field( attrs, "padding_left"   );
        padding_top    = Reflect.field( attrs, "padding_top"    );
        padding_right  = Reflect.field( attrs, "padding_right"  );
        padding_bottom = Reflect.field( attrs, "padding_bottom" );
        margin         = Reflect.field( attrs, "margin"         );
        margin_left    = Reflect.field( attrs, "margin_left"    );
        margin_top     = Reflect.field( attrs, "margin_top"     );
        margin_right   = Reflect.field( attrs, "margin_right"   );
        margin_bottom  = Reflect.field( attrs, "margin_bottom"  );
        border         = Reflect.field( attrs, "border"         );
        border_left    = Reflect.field( attrs, "border_left"    );
        border_top     = Reflect.field( attrs, "border_top"     );
        border_right   = Reflect.field( attrs, "border_right"   );
        border_bottom  = Reflect.field( attrs, "border_bottom"  );

        this.convertWidthAndHeight( attrs );
        this.convertStretch( attrs );
    }

    private function convertWidthAndHeight( attrs:Dynamic ) {
       width = Reflect.field( attrs, "width" );
        if (width == null) {
            width = 0;
            default_width = true;
        } else {
            default_width = false;
        }

        height = Reflect.field( attrs, "height" );
        if (height == null) {
            height = 0;
            default_height = true;
        } else {
            default_height = false;
        }
    }

    private function convertStretch( attrs:Dynamic ) {
        stretch_horizontal = 0.0;
        stretch_vertical   = 0.0;

        var stretch = Reflect.field( attrs, "stretch" );
        if (stretch != null) {
            stretch_horizontal = stretch;
            stretch_vertical   = stretch;
        }

        // scale between 0.0 - 1.0, stretchs width/height in relation
        // to its container
        var sh = Reflect.field( attrs, "stretch_horizontal" );
        if (sh != null) {
            stretch_horizontal = sh;
        }
        var sv = Reflect.field( attrs, "stretch_vertical" );
        if (sv != null) {
            stretch_vertical = sv;
        }

        if (stretch_horizontal > 1.0) stretch_horizontal = 1.0;
        if (stretch_horizontal < 0.0) stretch_horizontal = 0.0;
        if (stretch_vertical   > 1.0) stretch_vertical   = 1.0;
        if (stretch_vertical   < 0.0) stretch_vertical   = 0.0;
    }
}

class Wall {
    public var left : Int;
    public var top  : Int;
    public var right : Int;
    public var bottom : Int;

    public function get( orientation:Alignment ) {
        switch( orientation ) {
            case LEFT:
                return left;
            case TOP:
                return top;
            case RIGHT:
                return right;
            case BOTTOM:
                return bottom;
            default:
                return null;
        }
    }

    public function fromAttrs( attrs:BoxAttrs, prefix:String ) {
        // attrs without suffixes should be the default value for all directions
        left   = fromAttr( attrs, prefix );
        top    = fromAttr( attrs, prefix );
        right  = fromAttr( attrs, prefix );
        bottom = fromAttr( attrs, prefix );

        left   = fromAttrWithPrefix( attrs, prefix, "left",   left   );
        top    = fromAttrWithPrefix( attrs, prefix, "top",    top    );
        right  = fromAttrWithPrefix( attrs, prefix, "right",  right  );
        bottom = fromAttrWithPrefix( attrs, prefix, "bottom", bottom );
    }

    private function fromAttr( attrs:BoxAttrs, attr:String, ?dval:Int = 0 ) {
        var value = Reflect.field( attrs, attr );
        if (value == null) {
            return dval;
        }
        return value;
    }

    private function fromAttrWithPrefix( attrs:BoxAttrs, prefix:String, direction:String, ?dval:Int = 0 ) {
        return fromAttr( attrs, prefix + "_" + direction, dval );
    }

    public function modify( op:Dynamic -> Dynamic -> Dynamic, value:Int,
                            ?orientation:Alignment = null ) {
        switch(orientation) {
            case LEFT:
                left = op(left, value);
            case RIGHT:
                right = op(right, value);
            case TOP:
                top = op(top, value);
            case BOTTOM:
                bottom = op(bottom, value);
            default:
                left    = op(left,   value);
                right   = op(right,  value);
                top     = op(top,    value);
                bottom  = op(bottom, value);
        }
    }

    public function add( value:Int, ?orientation:Alignment = null ) {
        this.modify( MathUtils.add(), value, orientation );
    }

    public function reduce( value:Int, ?orientation:Alignment = null ) {
        this.modify( MathUtils.subtract(), value, orientation );
    }
}

class Position {
    public var x : Int;
    public var y : Int;

    public function new( x:Int, y:Int ) {
        this.x = x;
        this.y = y;
    }
}

class Margin extends Wall {
    public function new( attrs:BoxAttrs ) {
        fromAttrs(attrs, "margin");
    }
}

class Padding extends Wall {
    public function new( attrs:BoxAttrs ) {
        fromAttrs(attrs, "padding");
    }
}

class Border extends Wall {
    public function new( attrs:BoxAttrs ) {
        fromAttrs(attrs, "border");
    }
}

class Box {

    public static var GFX : Dynamic;

    var _align : Alignment;

    var _content_width : Int;
    var _content_height : Int;

    // original points
    var _po : Position;
    // margin points
    var _pm : Position;
    // border points
    var _pb : Position;
    // padding points
    var _pp : Position;
    // end padding points
    var _epp : Position;
    // end border points
    var _epb : Position;
    // end margin points
    var _epm : Position;
    // end original points
    var _epo : Position;

    var _padded_width : Int;
    var _padded_height : Int;
    var _bordered_width : Int;
    var _bordered_height : Int;
    var _margined_width : Int;
    var _margined_height : Int;

    var _margin  : Margin;
    var _padding : Padding;
    var _border  : Border;

    var _stretch_horizontal : Float;
    var _stretch_vertical   : Float;

    public var default_width : Bool;
    public var default_height : Bool;

    public function new( kwargs:Dynamic ) {
        var attrs:BoxAttrs = new BoxAttrs(kwargs);
        _po = new Position(0,0);
        _pm = new Position(0,0);
        _pb = new Position(0,0);
        _pp = new Position(0,0);
        _epp = new Position(0,0);
        _epb = new Position(0,0);
        _epm = new Position(0,0);
        _epo = new Position(0,0);
        _padding = new Padding(attrs);
        _margin  = new Margin(attrs);
        _border  = new Border(attrs);
        _align   = attrs.align;

        _stretch_horizontal = attrs.stretch_horizontal;
        _stretch_vertical   = attrs.stretch_vertical;

        /*
        The usable width and height defaults to total screen resolution.
        HBox and VBox make sure the childrens' usable width/height are
        restricted. default_width/default_height are used by Containers
        when calculating stacked children containers. Users can specify
        a fixed width/height to allocate.
        */
        this.setWidth( attrs.width );
        this.setHeight( attrs.height );
        default_width = attrs.default_width;
        default_height = attrs.default_height;

        this.updateBox();
    }

    public function setWidth( width:Int ) {
        if ( width > GFX.getWidth() || width == 0 ) {
            _content_width = Box.GFX.getWidth();
        } else {
            _content_width = width;
        }
    }

    public function setHeight( height:Int ) {
        if ( height > GFX.getHeight() || height == 0 ) {
            _content_height = Box.GFX.getHeight();
        } else {
            _content_height = height;
        }
    }

    public function updateBox() {
        this.setPos( this.getOriginalPoint() );
    }

    public function setPos( pos:Position ) {
        _po = pos;

        this.calculateInternalPoints();
        this.recalculateWidthAndHeight();
    }

    public function calculateInternalPoints() {
        // margin points
        _pm.x = _po.x + this.getMargin(Alignment.LEFT);
        _pm.y = _po.y + this.getMargin(Alignment.TOP);

        // border points
        _pb.x = _pm.x + this.getBorder(Alignment.LEFT);
        _pb.y = _pm.y + this.getBorder(Alignment.TOP);

        // padding points
        _pp.x = _pb.x + this.getPadding(Alignment.LEFT);
        _pp.y = _pb.y + this.getPadding(Alignment.TOP);

        // end padding points
        _epp.x = _pp.x + this.getContentWidth();
        _epp.y = _pp.y + this.getContentHeight();

        // end border points
        _epb.x = _epp.x + this.getPadding(Alignment.RIGHT);
        _epb.y = _epp.y + this.getPadding(Alignment.BOTTOM);

        // end margin points
        _epm.x = _epb.x + this.getBorder(Alignment.RIGHT);
        _epm.y = _epb.y + this.getBorder(Alignment.BOTTOM);

        // end original points
        _epo.x = _epm.x + this.getMargin(Alignment.RIGHT);
        _epo.y = _epm.y + this.getMargin(Alignment.BOTTOM);
    }

    public function recalculateWidthAndHeight() {
        _padded_width    = _epb.x - _pb.x;
        _padded_height   = _epb.y - _pb.y;
        _bordered_width  = _epm.x - _pm.x;
        _bordered_height = _epm.y - _pm.x;
        _margined_width  = _epo.x - _po.x;
        _margined_height = _epo.y - _po.y;
    }

    public function getOriginalPoint() {
        return _po;
    }

    public function getMarginPoint() {
        return _pm;
    }

    public function getBorderPoint() {
        return _pb;
    }

    public function getPaddingPoint() {
        return _pp;
    }

    public function getOriginalEndPoint() {
        return _epo;
    }

    public function getMarginEndPoint() {
        return _epm;
    }

    public function getBorderEndPoint() {
        return _epb;
    }

    public function getPaddingEndPoint() {
        return _epp;
    }

    public function getContentWidth() {
        return _content_width;
    }

    public function getContentHeight() {
        return _content_height;
    }

    public function getPaddedWidth() {
        return _padded_width;
    }

    public function getPaddedHeight() {
        return _padded_height;
    }

    public function getBorderedWidth() {
        return _bordered_width;
    }

    public function getBorderedHeight() {
        return _bordered_height;
    }

    public function getMarginedWidth() {
        return _margined_width;
    }

    public function getMarginedHeight() {
        return _margined_height;
    }

    public function getMargin( orientation:Alignment ) {
        return _margin.get(orientation);
    }

    public function getBorder( orientation:Alignment ) {
        return _margin.get(orientation);
    }

    public function getPadding( orientation:Alignment ) {
        return _padding.get(orientation);
    }

    public static function setGfxService( gfx ) {
        Box.GFX = gfx;
    }

    public function stretchTo( width:Int, height:Int ) {
        // note that when stretching we have to keep all parameters in mind
        if (_stretch_horizontal != 0) {
            var actual_width = cast(width * _stretch_horizontal, Int);
            actual_width = actual_width - (this.getMargin(Alignment.LEFT)
                                        +  this.getBorder(Alignment.LEFT)
                                        +  this.getPadding(Alignment.LEFT));
            actual_width = actual_width - (this.getMargin(Alignment.RIGHT)
                                        +  this.getBorder(Alignment.RIGHT)
                                        +  this.getPadding(Alignment.RIGHT));
            this.setWidth(Std.int(actual_width));
        }
        if (_stretch_vertical != 0) {
            var actual_height = height * _stretch_vertical;
            actual_height = actual_height - (this.getMargin(Alignment.TOP)
                                          +  this.getBorder(Alignment.TOP)
                                          +  this.getPadding(Alignment.TOP));
            actual_height = actual_height - (this.getMargin(Alignment.BOTTOM)
                                          +  this.getBorder(Alignment.BOTTOM)
                                          +  this.getPadding(Alignment.BOTTOM));
            this.setHeight(Std.int(actual_height));
        }
    }

    public function addPadding( value:Int, ?orientation:Alignment = null ) {
        _padding.add( value, orientation );
        this.updateBox();
    }

    public function reducePadding( value:Int, ?orientation:Alignment = null ) {
        _padding.reduce( value, orientation );
        this.updateBox();
    }

    public function addBorder( value:Int, ?orientation:Alignment = null ) {
        _border.add( value, orientation );
        this.updateBox();
    }

    public function reduceBorder( value:Int, ?orientation:Alignment = null ) {
        _border.reduce( value, orientation );
        this.updateBox();
    }

    public function addMargin( value:Int, ?orientation:Alignment = null ) {
        _margin.add( value, orientation );
        this.updateBox();
    }

}

class CompositeBox extends Box {

    var _children : Array<Box>;

    public var children(getChildren, null) : Array<Box>;

    public function new( children:Array<Box>, ?kwargs:Dynamic = null ) {
        _children = children;
        super(kwargs);
    }

    public function doInit() {

    }

    public function getChildren() { return _children; }

    public function add( child:Box ) {
        _children.push(child);
    }

    public override function setHeight( height:Int ) {
        // We have to constrain all children containers too, when
        // setting this height.
        super.setHeight( height );
        for ( child in _children ) {
            if ( Std.is( child, CompositeBox ) ) {
                if ( child.default_height ) {
                    child.setHeight(height);
                }
            }
        }
    }

    public override function setWidth( width:Int ) {
        super.setWidth( width );
        for ( child in _children ) {
            if ( Std.is( child, CompositeBox ) ) {
                if ( child.default_width ) {
                    child.setWidth(width);
                }
            }
        }
    }

    public override function getContentWidth() {
        // for containers we want them to maintain the total
        // available space. Thus all margins, borders and paddings
        // shrink the actual content_width and content_height
        var shrinked_width = _content_width;
        shrinked_width -= this.getMargin(Alignment.LEFT)
                        + this.getBorder(Alignment.LEFT)
                        + this.getPadding(Alignment.LEFT);
        shrinked_width -= this.getMargin(Alignment.RIGHT)
                        + this.getBorder(Alignment.RIGHT)
                        + this.getPadding(Alignment.RIGHT);
        return shrinked_width;
    }

    public override function getContentHeight() {
        var shrinked_height = _content_height;
        shrinked_height = shrinked_height - (this.getMargin(Alignment.TOP)
                                          +  this.getBorder(Alignment.TOP)
                                          +  this.getPadding(Alignment.TOP));
        shrinked_height = shrinked_height - (this.getMargin(Alignment.BOTTOM)
                                          +  this.getBorder(Alignment.BOTTOM)
                                          +  this.getPadding(Alignment.BOTTOM));
        return shrinked_height;
    }

    public function findMaxChildHeight() {
        var height = -1;
        for ( child in _children ) {
            if ( child.getMarginedHeight() > height ) {
                height = child.getMarginedHeight();
            }
            if ( Std.is(child, CompositeBox) ) {
                var h = cast(child, CompositeBox).findMaxChildHeight();
                if (h > height) {
                    height = h;
                }
            }
        }
        return height;
    }

    public function findMaxChildWidth() {
        var width = -1;
        for ( child in _children ) {
            if ( child.getMarginedWidth() > width ) {
                width = child.getMarginedWidth();
            }
            if ( Std.is(child, CompositeBox) ) {
                var w = cast(child, CompositeBox).findMaxChildWidth();
                if (w > width) {
                    width = w;
                }
            }
        }
        return width;
    }

    private function sum( it ) {
        return Lambda.fold(it, function(n, total) { return total += n; }, 0);
    }

    public function getChildrenWidth() {
        // get the sum of children widths
        return sum(
            Lambda.map( _children, function(x) { return x.getMarginedWidth(); })
        );
    }

    public function getChildrenHeight() {
        // get the sum of children heights
        return sum(
            Lambda.map( _children, function(x) { return x.getMarginedHeight(); })
        );
    }

    public function collectChildContainers( attr:String ) {
        // attr can be "default_width" or "default_height"
        //
        // divide child containers in default and non-default sized ones.
        // Default-sized means that no explicit width or height has been set.
        var default_size_containers     = new Array<Box>();
        var non_default_size_containers = new Array<Box>();
        var default_size_children       = new Array<Box>();
        var non_default_size_children   = new Array<Box>();

        for ( child in _children ) {
            if ( Std.is(child, CompositeBox) ) {
                if ( Reflect.field(child,attr) ) {
                    default_size_containers.push(child);
                } else {
                    non_default_size_containers.push(child);
                }
            } else {
                if ( Reflect.field(child,attr) ) {
                    default_size_children.push(child);
                } else {
                    non_default_size_children.push(child);
                }
            }
        }

        return [default_size_containers,
                non_default_size_containers,
                default_size_children,
                non_default_size_children];
    }

    private function call( x:Dynamic, field_name:String, ?args:Array<Dynamic> = null ) {
        if (args == null) {
            args = [];
        }
        return Reflect.callMethod(x, Reflect.field(x, field_name), args);
    }

    public function calculateAllocatableSize( container_attr:String,
                                              children_attr:String,
                                              default_size_containers:Array<Box>,
                                              non_default_size_containers:Array<Box>,
                                              default_size_children:Array<Box>,
                                              non_default_size_children:Array<Box> ) {
        var self = this;
        var reserved_size = sum(Lambda.map( non_default_size_containers,
                                            function(x) {
                                                return self.call(x, container_attr);
                                            }));
        reserved_size = reserved_size +
                        sum(Lambda.map(
                            non_default_size_children,
                            function(x) {
                                return self.call(x, children_attr);
                            }));
        // TODO: need (this) context with call or not?
        var allocatable_size = Reflect.field(this, container_attr)() - reserved_size;
        var n = 0;
        if (default_size_containers.length > 0) {
            n = n + default_size_containers.length;
        }
        if (default_size_children.length > 0) {
            n = n + default_size_children.length;
        }
        var single_allocatable = allocatable_size;
        if ( n > 0 ) {
            single_allocatable /= n;
        }
        return single_allocatable;
    }

    public function calculateAllocatableWidth() {
        // calculates the width a single container within a set of default
        // width containers can occupy
        var containers = this.collectChildContainers("default_width");
        var args:Array<Dynamic> = new Array<Dynamic>();
        args.push("getContentWidth");
        args.push("getMarginedWidth");
        return Reflect.callMethod(this, Reflect.field(this, "calculateAllocatableSize"), args.concat(containers));
    }

    public function calculateAllocatableHeight() {
        var containers = this.collectChildContainers("default_height");
        var args:Array<Dynamic> = new Array<Dynamic>();
        args.push("getContentHeight");
        args.push("getMarginedHeight");
        return Reflect.callMethod(this, Reflect.field(this, "calculateAllocatableSize"), args.concat(containers));
    }

    public function calculateAlignOffset( ?attr:String = "getChildrenWidth" ) {
        // alignment (affected via padding)
        var targetX      = null;
        var align_offset = null;
        if (_align == Alignment.CENTER) {
            targetX  = (this.getContentWidth() / 2);
            targetX -= this.call(this, attr) / 2;
        } else if (_align == Alignment.RIGHT) {
            targetX = this.getContentWidth() - this.call(this, attr);
        }

        if (targetX != null) {
            // the point where the actual content starts after padding
            var align_offset = targetX - this.getPadding(Alignment.LEFT);
            return align_offset;
        }
        return null;
    }

    
}
