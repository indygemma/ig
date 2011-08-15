package ig.core;

import ig.aspects.Aspect;

class Actor {

    var _name : String;
    var _aspects : Array<Dynamic>; // [AspectClass, [AspectClass, { arg1 : val1, ... }], ...]

    public var name(getName, setName) : String;
    public var aspects(getAspects, setAspects) : Array<Dynamic>;

    public function new() {

    }

    public function getName() : String {
        return _name;
    }

    public function setName( name:String ) : String {
        _name = name;
        return _name;
    }

    public function getAspects() : Array<Dynamic> {
        return _aspects;
    }

    public function setAspects( aspects:Array<Dynamic> ) : Array<Dynamic> {
        _aspects = aspects;
        return _aspects;
    }

    public function getAspectClass( aspect_class:Class<Aspect> ) {
        
    }
}
