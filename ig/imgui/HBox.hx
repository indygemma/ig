package ig.imgui;

import ig.imgui.Box;

class HBox extends CompositeBox {

    public function new( items:Array<Box>, ?kwargs:Dynamic = null ) {
        super(items, kwargs);
        this.doInit();
    }

    public override function doInit() {
        var align_offset = this.calculateAlignOffset("getChildrenWidth");
        // update children positions
        var single_allocatable_width = this.calculateAllocatableWidth();
        var pp = this.getPaddingPoint();
        var current_posX = pp.x;
        var current_posY = pp.y;
        if (align_offset != null) {
            current_posX += Std.int( align_offset );
        }

        // find minimum height
        var max_height = this.findMaxChildHeight();
        for ( child in _children ) {
            if ( Std.is(child, CompositeBox) ) {
                // TODO: do I need more casting?
                if ( child.default_width ) {
                    child.setWidth(single_allocatable_width);
                }
                // make sure children's max height is the same as this container's
                child.setHeight( this.getContentHeight() );
                child.setPos(new Position(current_posX, current_posY));
                current_posX = current_posX + child.getMarginedWidth();
                cast(child, CompositeBox).doInit();
            } else {
                // make sure children's max height is the same as this container's
                child.stretchTo( this.getContentWidth(), this.getContentHeight() );
                child.setPos(new Position(current_posX, current_posY));
                current_posX = current_posX + child.getMarginedWidth();
            }
        }
    }

    public function getPaddingWidth() {
        return this.getPadding(Alignment.LEFT) + this.getChildrenWidth() + this.getPadding(Alignment.RIGHT);
    }

    public function getPaddingHeight() {
        return this.getPadding(Alignment.TOP) + this.findMaxChildHeight() + this.getPadding(Alignment.BOTTOM);
    }

}
