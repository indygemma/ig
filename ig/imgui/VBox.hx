package ig.imgui;

import ig.imgui.Box;

class VBox extends CompositeBox {

    public function new( items:Array<Box>, ?kwargs:Dynamic = null ) {
        super(items, kwargs);
        this.doInit();
    }

    public override function doInit() {
        var align_offset = this.calculateAlignOffset("findMaxChildWidth");
        var single_allocatable_height = this.calculateAllocatableHeight();
        var pp = this.getPaddingPoint();
        var current_posX = pp.x;
        var current_posY = pp.y;
        if (align_offset != null) {
            current_posX += Std.int(align_offset);
        }

        for ( child in _children ) {
            if ( Std.is(child, CompositeBox) ) {
                if (child.default_height) {
                    child.setHeight(single_allocatable_height);
                }
                // make sure children's max width is same as this container's
                child.setWidth( this.getContentWidth() );
                child.setPos( new Position(current_posX, current_posY) );
                current_posY += child.getMarginedHeight();
                cast(child,CompositeBox).doInit();
            } else {
                child.stretchTo(this.getContentWidth(), single_allocatable_height);
                child.setPos( new Position(current_posX, current_posY) );
                current_posY += child.getMarginedHeight();
            }
        }
    }

    public function getPaddingWidth() {
        return this.getPadding(Alignment.LEFT) + this.findMaxChildWidth() + this.getPadding(Alignment.RIGHT);
    }

    public function getPaddingHeight() {
        return this.getPadding(Alignment.TOP) + this.getChildrenHeight() + this.getPadding(Alignment.BOTTOM);
    }

}
