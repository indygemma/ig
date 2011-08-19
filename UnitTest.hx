import tests.ApplicationTest;
import tests.AspectTest;
import tests.SingletonTest;
import tests.LayoutTest;

class UnitTest {
    public static function main() {
        var r = new haxe.unit.TestRunner();
        r.add(new ApplicationTest());
        r.add(new AspectTest());
        r.add(new SingletonTest());
        r.add(new LayoutTest());
        r.run();
    }
}
