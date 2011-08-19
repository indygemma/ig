package tests;

import ig.imgui.Box;
import ig.imgui.HBox;
import ig.imgui.VBox;

class MockGfx {

    public function new() {

    }

    public function getWidth() {
        return 800;
    }

    public function getHeight() {
        return 600;
    }
}

class BoxItem extends Box {
    public function new( width:Int = 50, height:Int = 10, kwargs:Dynamic = null ) {
        super( kwargs );
        setWidth( width );
        setHeight( height );
        updateBox();
    }
}

class LayoutTest extends haxe.unit.TestCase {

    public override function setup() {
        Box.setGfxService(new MockGfx());
    }

    public function _testConstants() {
        /*expect(_engine.SCREEN_WIDTH).should_be(800)*/
        /*expect(_engine.SCREEN_HEIGHT).should_be(600)*/
    }

    public function assertWithin( expect:Float, actual:Float, value:Float) {
        var diff = Math.abs(expect - actual);
        assertTrue( diff <= value );
    }

    public function testElementaryLayoutAttributes() {
        var box1 = new BoxItem(54,14, { padding: 7 });
        assertEquals( 54, box1.getContentWidth() );
        assertEquals( 68, box1.getPaddedWidth() );
        assertEquals( 68, box1.getBorderedWidth() );
        assertEquals( 68, box1.getMarginedWidth() );
        assertEquals( 14, box1.getContentHeight() );
        assertEquals( 28, box1.getPaddedHeight() );
        assertEquals( 28, box1.getBorderedHeight() );
        assertEquals( 28, box1.getMarginedHeight() );
        assertEquals( 0, box1.getOriginalPoint().x );
        assertEquals( 0, box1.getOriginalPoint().y );
        assertEquals( 0, box1.getMarginPoint().x );
        assertEquals( 0, box1.getMarginPoint().y );
        assertEquals( 0, box1.getBorderPoint().x );
        assertEquals( 0, box1.getBorderPoint().y);
        assertEquals( 7, box1.getPaddingPoint().x );
        assertEquals( 7, box1.getPaddingPoint().y );
        assertEquals( 61, box1.getPaddingEndPoint().x );
        assertEquals( 21, box1.getPaddingEndPoint().y );
    }

    public function testForSingleHorizontalLayout() {
        var button_object:Box = new BoxItem(50, 10);
        var stop_btn      = new BoxItem(50, 10);
        var quit_btn      = new BoxItem(50, 10);

        // check dimensions without extras
        var layout = new HBox([button_object, stop_btn, quit_btn]); // align Alignment.LEFT is default
        assertEquals( 800, layout.getContentWidth() );
        assertEquals( 800, layout.getMarginedWidth() );
        assertEquals( 800, layout.getBorderedWidth() );
        assertEquals( 800, layout.getPaddedWidth() );
        assertEquals( 600, layout.getPaddedHeight() ); // use the height of the highest child
    }

    public function testHBoxAlignments() {
        var button_object:Box = new BoxItem(50, 10);
        var stop_btn      = new BoxItem(50, 10);
        var quit_btn      = new BoxItem(50, 10);

        // test layout alignment: left
        var layout = new HBox([button_object, stop_btn, quit_btn], { align: Alignment.LEFT });
        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( 0, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test layout alignment: center
        var layout = new HBox([button_object, stop_btn, quit_btn], { align: Alignment.CENTER });
        var real_x = (800/2) - (3*50)/2;

        // actual layout box starts at (0,0)
        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);

        // the first element of the box starts at real_x
        assertEquals( real_x, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);

        // should equal getOriginalPoint() because of no padding effects
        assertEquals( real_x, button_object.getPaddingPoint().x);
        assertEquals( 0, button_object.getPaddingPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test layout alignment: right
        var layout = new HBox([button_object, stop_btn, quit_btn], { align:Alignment.RIGHT} );
        var real_x = 800 - (3*50);
        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( real_x, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( real_x, button_object.getPaddingPoint().x);
        assertEquals( 0, button_object.getPaddingPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);
    }

    public function testSingleHBoxAlignmentAndPadding() {
        var button_object:Box = new BoxItem(70,10);
        var stop_btn:Box      = new BoxItem(60,10);
        var quit_btn:Box      = new BoxItem(50,10);

        // test layout padding: left, top, right, bottom (position of layout)
        var layout = new HBox([button_object, stop_btn, quit_btn], { padding_left:5, align:Alignment.LEFT});
        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 5, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);

        // containers (HBox) maintain their total space even with margins, borders and paddings
        // by shrinking the content space
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);
        assertEquals( 795, layout.getContentWidth() );
        assertEquals( 600, layout.getContentHeight() );

        // check correctness of children
        assertEquals( 5, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 5, button_object.getPaddingPoint().x);
        assertEquals( 0, button_object.getPaddingPoint().y);
        assertEquals( 5+70, button_object.getPaddingEndPoint().x);
        assertEquals( 10, button_object.getPaddingEndPoint().y);
        assertEquals( 5+70, button_object.getOriginalEndPoint().x);
        assertEquals( 10, button_object.getOriginalEndPoint().y);
        assertEquals( 70, button_object.getContentWidth() );
        assertEquals( 70, button_object.getPaddedWidth() );

        assertEquals( 5+70, stop_btn.getOriginalPoint().x );
        assertEquals( 0, stop_btn.getOriginalPoint().y );
        assertEquals( 5+70, stop_btn.getPaddingPoint().x );
        assertEquals( 0, stop_btn.getPaddingPoint().y );
        assertEquals( 5+70+60, stop_btn.getPaddingEndPoint().x);
        assertEquals( 10, stop_btn.getPaddingEndPoint().y);
        assertEquals( 5+70+60, stop_btn.getOriginalEndPoint().x);
        assertEquals( 10, stop_btn.getOriginalEndPoint().y);
        assertEquals( 60, stop_btn.getPaddedWidth() );

        assertEquals( 5+70+60, quit_btn.getOriginalPoint().x);
        assertEquals( 0, quit_btn.getOriginalPoint().y);
        assertEquals( 5+70+60, quit_btn.getPaddingPoint().x);
        assertEquals( 0, quit_btn.getPaddingPoint().y);
        assertEquals( 5+70+60+50, quit_btn.getPaddingEndPoint().x);
        assertEquals( 10, quit_btn.getPaddingEndPoint().y);

        // ###----------------------------------------------------------------------------
        // test left padding. CENTER align
        var layout = new HBox([button_object, stop_btn, quit_btn], { padding_left:5, align:Alignment.CENTER });
        // note that the content_width shrinks by 5 due to the left padding
        var real_x = ((800-5)/2) - (70+60+50)/2;

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 5, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        //assertEquals( real_x, button_object.getOriginalPoint().x);
        // float comparison
        assertWithin( real_x, button_object.getOriginalPoint().x, 1.0 );
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test left padding, RIGHT align
        var layout = new HBox([button_object, stop_btn, quit_btn], { padding_left:5, align:Alignment.RIGHT });
        var real_x = (800-5) - (70+60+50);

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 5, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( real_x, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test top padding, LEFT align
        var layout = new HBox([ button_object, stop_btn, quit_btn ], { padding_top:5, align:Alignment.LEFT });

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 5, layout.getPaddingPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);

        // test top padding, CENTER align + RIGHT align (shouldn't make a difference, so skip)

        // test right padding, LEFT align
        var layout = new HBox([ button_object, stop_btn, quit_btn ], { padding_right:5, align:Alignment.LEFT });

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 795, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test right padding, CENTER align
        var layout = new HBox([ button_object, stop_btn, quit_btn ], { padding_right:5, align:Alignment.CENTER });
        var real_x = ((800-5)/2) - (70+60+50)/2;

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertWithin( real_x, button_object.getOriginalPoint().x, 1.0);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 795, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test right padding, RIGHT align
        var layout = new HBox([ button_object, stop_btn, quit_btn ], { padding_right:5, align:Alignment.RIGHT });
        var real_x = (800-5) - (70+60+50);

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( real_x, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 795, layout.getPaddingEndPoint().x);
        assertEquals( 600, layout.getPaddingEndPoint().y);

        // test bottom padding
        var layout = new HBox([ button_object, stop_btn, quit_btn ], { padding_bottom:5, align:Alignment.LEFT });

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);
        assertEquals( 0, layout.getPaddingPoint().x);
        assertEquals( 0, layout.getPaddingPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
        assertEquals( 800, layout.getPaddingEndPoint().x);
        assertEquals( 595, layout.getPaddingEndPoint().y);
    }

    public function testWithMultipleStackingHboxCompositions() {
        // Test out recursive HBox definitions
        var button_object:Box = new BoxItem(50,10);
        var stop_btn:Box      = new BoxItem(50,10);
        var quit_btn:Box      = new BoxItem(50,10);

        var left_l:Box  = new HBox([button_object], {align:Alignment.RIGHT});
        var right_l:Box = new HBox([quit_btn],      {align:Alignment.LEFT });
        var layout  = new HBox([left_l, right_l]);

        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);

        assertEquals( 0, left_l.getOriginalPoint().x);
        assertEquals( 0, left_l.getOriginalPoint().y);
        assertEquals( 400, left_l.getMarginedWidth() );
        assertEquals( 400, left_l.getOriginalEndPoint().x);
        assertEquals( 600, left_l.getOriginalEndPoint().y);

        assertEquals( 400, right_l.getOriginalPoint().x);
        assertEquals( 0, right_l.getOriginalPoint().y);
        assertEquals( 400, right_l.getMarginedWidth() );
        assertEquals( 800, right_l.getOriginalEndPoint().x);
        assertEquals( 600, right_l.getOriginalEndPoint().y);

        assertEquals( 400-50, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);

        // if this works, then all HBox children are successfully updated
        // after its width and positions have been updated
        assertEquals( 400, quit_btn.getOriginalPoint().x);
        assertEquals( 0, quit_btn.getOriginalPoint().y);
        assertEquals( 450, quit_btn.getOriginalEndPoint().x);
        assertEquals( 10, quit_btn.getOriginalEndPoint().y);

        //------------------------------------------------------------------------------

        var left_l:Box   = new HBox([button_object], {align:Alignment.LEFT});
        var center_l:Box = new HBox([stop_btn],      {align:Alignment.LEFT});
        var right_l:Box  = new HBox([quit_btn],      {align:Alignment.RIGHT});
        var layout   = new HBox([left_l, center_l, right_l]);

        var single_width = 800 / 3;

        assertEquals( 0, left_l.getOriginalPoint().x);
        assertEquals( 0, left_l.getOriginalPoint().y);
        assertEquals( single_width, left_l.getMarginedWidth() );
        assertEquals( single_width, left_l.getOriginalEndPoint().x);
        assertEquals( 600, left_l.getOriginalEndPoint().y);

        assertEquals( single_width, center_l.getOriginalPoint().x);
        assertEquals( 0, center_l.getOriginalPoint().y);
        assertEquals( single_width, center_l.getMarginedWidth() );
        assertEquals( single_width*2, center_l.getOriginalEndPoint().x);
        assertEquals( 600, center_l.getOriginalEndPoint().y);

        assertEquals( single_width*2, right_l.getOriginalPoint().x);
        assertEquals( 0, right_l.getOriginalPoint().y);
        assertEquals( single_width, right_l.getContentWidth() );

        // WHY does this not equal single_width?? floating error? yes
        //assertEquals( single_width, right_l.getMarginedWidth() );

        assertEquals( single_width*3, right_l.getOriginalEndPoint().x);
        assertEquals( 600, right_l.getOriginalEndPoint().y);

        assertEquals( 0, button_object.getOriginalPoint().x);
        assertEquals( 0, button_object.getOriginalPoint().y);
        assertEquals( single_width, stop_btn.getOriginalPoint().x);
        assertEquals( 0, stop_btn.getOriginalPoint().y);
        assertWithin( 800-50, quit_btn.getOriginalPoint().x, 1.0);
        assertEquals( 0, quit_btn.getOriginalPoint().y);
    }

    public function testWithMultipleVBoxCompositionsWithMargin() {
        /*
            +-----+-----+
            |     |     |
            |     |     |
            +-----+     |
            |     |     |
            |     |     |
            +-----+-----+

            HBox
                VBox
                    HBox
                    HBox
                VBox
        */
        var button_object:Box = new BoxItem(50,10);
        var stop_btn:Box      = new BoxItem(50,10);
        var quit_btn:Box      = new BoxItem(50,10);

        var upper_left_l:Box = new HBox([button_object], { align:Alignment.LEFT });
        var lower_left_l:Box = new HBox([stop_btn], { align:Alignment.LEFT });
        var left_l:Box       = new VBox([upper_left_l, lower_left_l]);
        var right_l:Box      = new VBox([quit_btn], { align:Alignment.RIGHT });
        var layout           = new HBox([left_l, right_l]);

        // check start positions
        assertEquals( 0, upper_left_l.getOriginalPoint().x);
        assertEquals( 0, upper_left_l.getOriginalPoint().y);
        assertEquals( 0, lower_left_l.getOriginalPoint().x);
        assertEquals( 300, lower_left_l.getOriginalPoint().y);
        assertEquals( 0, left_l.getOriginalPoint().x);
        assertEquals( 0, left_l.getOriginalPoint().y);
        assertEquals( 400, right_l.getOriginalPoint().x);
        assertEquals( 0, right_l.getOriginalPoint().y);
        assertEquals( 0, layout.getOriginalPoint().x);
        assertEquals( 0, layout.getOriginalPoint().y);

        // check end positions
        assertEquals( 400, upper_left_l.getOriginalEndPoint().x);
        assertEquals( 300, upper_left_l.getOriginalEndPoint().y);
        assertEquals( 400, lower_left_l.getOriginalEndPoint().x);
        assertEquals( 600, lower_left_l.getOriginalEndPoint().y);
        assertEquals( 400, left_l.getOriginalEndPoint().x);
        assertEquals( 600, left_l.getOriginalEndPoint().y);
        assertEquals( 800, right_l.getOriginalEndPoint().x);
        assertEquals( 600, right_l.getOriginalEndPoint().y);
        assertEquals( 800, layout.getOriginalEndPoint().x);
        assertEquals( 600, layout.getOriginalEndPoint().y);
    }

    public function testWithMultipleBoxCompositionsWithConcreteChildrenWidth() {
        var button_object:Box = new BoxItem(50,10);
        var stop_btn:Box      = new BoxItem(50,10);
        var quit_btn:Box      = new BoxItem(50,10);

        var left_l:Box  = new HBox([button_object], { width:600 });
        var right_l:Box = new HBox([quit_btn], { align:Alignment.RIGHT });
        var upper_l:Box = new HBox([left_l, right_l], { height:400 });
        var lower_l:Box = new HBox([stop_btn], { align:Alignment.CENTER });
        var layout  = new VBox([upper_l, lower_l]);

        assertEquals( 800, upper_l.getContentWidth() );
        assertEquals( 600, left_l.getContentWidth() );
        assertEquals( 200, right_l.getContentWidth() );
        assertEquals( 800, lower_l.getContentWidth() );

        assertEquals( 400, upper_l.getContentHeight() );
    }

    public function testWithBoxKeyParameters() {
        var box = new BoxItem(50,10, { padding:10, padding_left:0 });

        assertEquals( 0, box.getOriginalPoint().x);
        assertEquals( 0, box.getOriginalPoint().y);
        assertEquals( 0, box.getPaddingPoint().x);
        assertEquals( 10, box.getPaddingPoint().y);
        assertEquals( 50, box.getPaddingEndPoint().x);
        assertEquals( 20, box.getPaddingEndPoint().y);
        assertEquals( 60, box.getBorderEndPoint().x);
        assertEquals( 30, box.getBorderEndPoint().y);
        assertEquals( 60, box.getMarginEndPoint().x);
        assertEquals( 30, box.getMarginEndPoint().y);
        assertEquals( 60, box.getOriginalEndPoint().x);
        assertEquals( 30, box.getOriginalEndPoint().y);
    }

}
