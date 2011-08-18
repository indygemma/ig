package ig.aspects;

import haxe.FastList;
import ig.core.Actor;
using ig.utils.Singleton;

typedef AspectList = FastList<Aspect>;

class AspectManager {

    var _actors : Hash<Actor>; // name -> actor class
    var _aspects : AspectList; // [aspect1, aspect2, ...]
    var _aspects_by_type : Hash<AspectList>; // { aspect_class_name : [
                                                   //     aspect1,
                                                   //     aspect2,
                                                   //     ...
                                                   //   ]
                                                   // }

    public function new() {
        _actors = new Hash<Actor>();
        _aspects = new FastList<Aspect>();
        _aspects_by_type = new Hash<AspectList>();
    }

    /*
    * registerActor -- register the actor class, and all the
    *                  associated aspect classes. This is handy
    *                  for later when querying all those aspect
    *                  classes with getAspectClasses(class)
    */
    public function registerActor( actor:Actor ) {
        _actors.set(actor.name, actor);
    }

    public function getActorClass( actor_name:String ) : Actor {
        return _actors.get(actor_name);
    }

    public function getActorsWithAspectClasses( aspect_class:Class<Aspect> ) : haxe.FastList<Actor> {
        var result = new haxe.FastList<Actor>();
        for ( actor in _actors ) {
            var matching_aspect = actor.getAspectClass(aspect_class);
            if (matching_aspect != null) {
                result.add(actor);
            }
        }
        return result;
    }

    /*
    * registerAspect -- register an aspect instance to the registry
    */
    public function registerAspect( aspect:Aspect ) {
        _aspects.add(aspect);
        var aspect_class = Type.getClassName(Type.getClass(aspect));
        if (!_aspects_by_type.exists(aspect_class)) {
            var aspect_class_list = new FastList<Aspect>();
            _aspects_by_type.set(aspect_class, aspect_class_list);
        }
        _aspects_by_type.get(aspect_class).add(aspect);
    }

    /*
    * getAspectsByType -- retrieve all aspect instances of a given type
    */
    public function getAspectsByType( aspect_class:Class<Aspect> ) : haxe.FastList<Aspect> {
        return _aspects_by_type.get(Type.getClassName(aspect_class));
    }

    public function verifyDependencies() {
        
    }

    public function update() {

    }

}
