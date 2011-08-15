class TestState extends ig.core.GameState {
    public var value : String;

    public function new() {
        super();
        this.value = "";
    }

    private function className() {
        return Type.getClassName(Type.getClass(this));
    }

    public override function onInit() {
        this.value = this.className() + ".onInit";
    }

    public override function onUpdate() {
        this.value = this.className() + ".onUpdate";
    }

    public override function onShutdown() {
        this.value = this.className() + ".onShutdown";
    }
}

class AState extends TestState {}
class BState extends TestState {}

class ApplicationTest extends haxe.unit.TestCase {
    public function testStateChange() {
        var app = new ig.core.Application();
        var state = new AState();
        assertEquals(state.value, "");

        // simplfy casting
        var val= function(app:ig.core.Application):String {
            return cast(app.state, TestState).value;
        };

        // changeState wants a new GameState instance
        app.changeState(state);
        assertEquals("AState.onInit", val(app));

        // changeState also accepts functions that return GameState objects
        app.changeState(function() {
            var newstate = new AState();
            newstate.value = "injecting pre-init logic";
            return newstate;
        });
        assertEquals("AState.onInit", val(app));

        app.update();
        assertEquals("AState.onUpdate", val(app));

        app.shutdown();
        assertEquals("AState.onShutdown", val(app));

        // now change to another state and make sure everything's correct
        app.changeState(function() { return new BState(); });
        assertEquals("BState.onInit", val(app));

        app.update();
        assertEquals("BState.onUpdate", val(app));

        app.shutdown();
        assertEquals("BState.onShutdown", val(app));
    }
}

class UnitTest {
    public static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new ApplicationTest());
        r.run();
    }
}
