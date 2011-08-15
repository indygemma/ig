package ig.aspects;

import ig.core.Actor;
import ig.utils.Singleton;

class AspectManager extends Singleton {

    var _actors : Hash<Actor>; // name -> actor class

    public function new() {
        _actors = new Hash<Actor>();
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
}
