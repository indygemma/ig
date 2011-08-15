package ig.utils;

class Singleton {

    static var _instances : Hash<Dynamic>;

    /*
    * getInstance -- return a singleton object for the supplied class.
    *                By using the 'using' mixin we can directly call
    *                this method as if it were member method. eg.
    *
    *                  using ig.utils.Singleton;
    *                  ...
    *                  TestSingleton.getInstance();
    *                  SomeClass.getInstance([3, 4]);
    */
    public static function getInstance( klass:Class<Dynamic>, ?args:Array<Dynamic> ) : Dynamic {
        if (_instances == null)
            _instances = new Hash<Dynamic>();
        var class_name = Type.getClassName(klass);
        if (_instances.exists(class_name)) return _instances.get(class_name);
        var real_args = (args == null) ? [] : args;
        var instance = Type.createInstance(klass, real_args);
        _instances.set(class_name, instance);
        return instance;
    }

}
