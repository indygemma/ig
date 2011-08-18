package ig.core;

import ig.aspects.Aspect;
import ig.aspects.AspectManager;
using ig.utils.Singleton;

class Actor {

    var _name : String;
    // [AspectClass, [AspectClass, { arg1 : val1, ... }], ...]
    var _aspects : Array<Dynamic>;
    // [aspect1, aspect2, ...]
    var _aspect_instances : Array<Aspect>;
    // NOTE: assumption is that there's only one aspect instance
    //       per type
    var _aspects_by_type : Hash<Aspect>;
    // unique id
    var _uuid : String;
    // whether to skip the next update
    public var skip_update : Bool;

    public var name(getName, setName) : String;
    public var aspects(getAspects, setAspects) : Array<Dynamic>;
    public var uuid(getUUID, setUUID) : String;
    public var aspect_instances(getAspectInstances, null) : Array<Aspect>;

    public function new() {
        _aspects = new Array<Dynamic>();
        _aspect_instances = new Array<Aspect>();
        _aspects_by_type = new Hash<Aspect>();
        skip_update = false;
    }

    public function setup() {

    }

    /*
    * initializeAspects
    *
    * initialize all registered aspects to this actor. on_setup_cb
    * holds a dictionary of "aspect name" -> callback to execute
    * post aspect construction.
    *
    * A sample use case is when someone calls
    *
    *   ActorManager.getInstance().create("penguin", callbacks);
    *
    * where 'callbacks' is defined as:
    *
    *   var callbacks = new Hash<Dynamic>();
    *   callbacks.set(Position, function(aspect) { aspect.set(x,y); });
    *   callbacks.set(MapItem, function(aspect)  { aspect.map = map2d });
    *
    * Notice that this saves implementing the special logic as a subclass of
    * "penguin". By defining the callbacks and having access to the proper closures
    * alot of flexibility is maintained.
    *
    * This aspect manipulation is done before the respective "postSetup" calls.
    *
    * If you DO want to manipulate the aspects AFTER postSetup, then you can
    * access them manually and update them accordingly. eg
    *
    *   var p = ActorManager.getInstance().create("penguin");
    *   p.getAspect(Position).set(10,15);
    *   p.getAspect(MapItem).map = map2d;
    * 
    */
    public function initializeAspects( ?on_setup_cb:Hash<Aspect -> Void> ) {
        for ( entry in _aspects ) {
            var aa = this.extractAspectClassEntry(entry);
            var a:Aspect = Type.createInstance(aa.aspect, aa.args);
            a.setActor(this);
            a.setup();
            var class_name = Type.getClassName(Type.getClass(a));
            if ((on_setup_cb != null) && on_setup_cb.exists(class_name)) {
                on_setup_cb.get(class_name)(a);
            }
            // store aspect in the type table
            _aspects_by_type.set(class_name, a);
            _aspect_instances.push(a);
            AspectManager.getInstance().registerAspect(a);
        }
    }

    public function postInitializeAspects() {
        for (aspect in _aspect_instances) {
            aspect.postSetup();
        }
    }

    /*
    * extractAspectClassEntry
    *
    * extract the aspect class and optional arguments from
    * an  _aspects entry.
    */
    private function extractAspectClassEntry( entry:Dynamic ) {
        if (Std.is(entry, Array)) {
            return { aspect: entry[0], args: entry[1] };
        } else {
            return { aspect: entry, args: [] };
        }
    }

    public function getName() : String {
        return _name;
    }

    public function setName( name:String ) : String {
        _name = name;
        return _name;
    }

    public function getAspect( aspect:Class<Aspect> ) : Aspect {
        var class_name = Type.getClassName(aspect);
        return _aspects_by_type.get( class_name );
    }

    public function getAspects() : Array<Dynamic> {
        return _aspects;
    }

    public function setAspects( aspects:Array<Dynamic> ) : Array<Dynamic> {
        _aspects = aspects;
        return _aspects;
    }

    /*
    * getAspectClass
    *
    * filter out those aspects that equal "aspect_class".
    * Handy when trying to figure out which aspects are
    * registered with which actors.
    *
    * TODO: The name should be refactored to a different name.
    *
    * returns { aspect: aspect_class, args: [arg1, arg2, ...] }
    * or null
    */
    public function getAspectClass( aspect_class:Class<Aspect> ) {
        // TODO: extract out general iteration
        for ( entry in _aspects ) {
            var aa = this.extractAspectClassEntry(entry);
            if ( aspect_class == aa.aspect ) {
                // TODO: create unit tests for this
                return aa;
            }
        }
        return null;
    }

    public function getUUID() {
        return _uuid;
    }

    public function setUUID( uuid:String ) {
        _uuid = uuid;
        return _uuid;
    }

    public function getAspectInstances() {
        return _aspect_instances;
    }

    /* Aspect Class manipulation. to be used within setup() */

    public function addAspect( aspect_class:Class<Aspect>, args:Array<Dynamic> ) {
        _aspects.push([aspect_class, args]);
    }

    /*
    * TODO: this is a highly inefficient procedure. improve it!
    *       may need another data structure to hold the aspects
    */
    public function removeAspect( aspect_class:Class<Aspect> ) {
        var idx:Int = 0;
        var found:Int = -1;
        for ( entry in _aspects ) {
            var aa = this.extractAspectClassEntry(entry);
            if ( aspect_class == aa.aspect ) {
                found = idx;
            }
            idx++;
        }
        if (found != -1) {
            _aspects = _aspects.splice(found, 1);
        }
    }

    public function changeAspect( aspect_class:Class<Aspect>, args:Array<Dynamic> ) {
        this.removeAspect( aspect_class );
        this.addAspect( aspect_class, args );
    }

    /*
    * preUpdate
    *
    * gets called before the aspects are updated
    *
    */
    public function preUpdate() {

    }

    /*
    * postUpdate
    *
    * gets called after the aspects are updated
    *
    */
    public function postUpdate() {

    }
}
