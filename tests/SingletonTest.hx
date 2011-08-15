package tests;

import ig.utils.Singleton;
using ig.utils.Singleton;

class TestSingleton {

    public static var counter : Int;

    public function new() {
        if (counter == null)
            counter = 0;
        counter++;
    }

}

class TestSingletonWithArgs {

    var x:Int;
    var y:Int;

    public function new(x:Int, y:Int) {
        this.x = x;
        this.y = y;
    }

}

class SingletonTest extends haxe.unit.TestCase {
    public function testSingleton() {
        var t1 = new TestSingleton();
        assertEquals(1, TestSingleton.counter);

        var t = Singleton.getInstance(TestSingleton);
        var t2 = Singleton.getInstance(TestSingleton);
        assertEquals(2, TestSingleton.counter);

        new TestSingleton();
        new TestSingleton();

        assertEquals(4, TestSingleton.counter);

        // now with 'using' syntax as mixin
        TestSingleton.getInstance();
        assertEquals(4, TestSingleton.counter);
    }

    public function testSingletonWithArgs() {
        var targs = TestSingletonWithArgs.getInstance([2,3]);
        assertEquals(2, targs.x);
        assertEquals(3, targs.y);
    }
}
