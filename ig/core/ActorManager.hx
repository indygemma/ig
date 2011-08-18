package ig.core;

import ig.core.Actor;
import ig.aspects.Aspect;
import ig.aspects.Sleepable;

using ig.utils.Singleton;

typedef ActorArray = Array<Actor>;

class ActorManager {

    // { "uuid" -> Actor instance }
    var _actors : Hash<Actor>;
    // { "name" -> [actor1, actor2, actor3, ...], ... }
    var _actors_by_name : Hash<ActorArray>;
    var _count : Int;

    public function new() {
        _actors = new Hash<Actor>();
        _actors_by_name = new Hash<ActorArray>();
        _count = 0;
    }

    public static function create( actor_class:Class<Actor>, ?on_setup_cb:Hash<Aspect -> Void> ) : Actor {
        // TODO: create is static, so client does not have to
        // call 'getInstance()' everytime. useful?
        var class_name = Type.getClassName(actor_class);
        var self:ActorManager = ActorManager.getInstance();

        // create a new actor instance based on the class
        var actor:Actor = Type.createInstance(actor_class, []);
        actor.setup();
        actor.uuid = self.createUniqueName( actor_class );

        // initialize all connected aspects
        actor.initializeAspects(on_setup_cb);
        actor.postInitializeAspects();

        self._actors.set(actor.uuid, actor);
        self._actors_by_name.get(class_name).push(actor);

        self._count += 1;

        return actor;
    }

    public static function update() {
        var self:ActorManager = ActorManager.getInstance();
        for ( uuid in self._actors.keys() ) {
            var actor = self._actors.get(uuid);
            if (!actor.skip_update) {
                actor.preUpdate();
                for ( aspect in actor.aspect_instances ) {
                    if (aspect.active) {
                        aspect.update();
                    }
                }
                actor.postUpdate();
            } else {
                // update the sleepable aspect associated with this actor
                // otherwise the actor won't wake up.
                var sleepable = cast(actor.getAspect(Sleepable), Sleepable);
                sleepable.update();
            }
        }
    }

    public function createUniqueName( actor_class:Class<Actor> ) : String {
        var class_name = Type.getClassName( actor_class );
        var actor_list:Array<Actor> = this.ensureActorListByNameExists( class_name );
        var count = actor_list.length;
        if (count != 0) {
            return class_name + count;
        }
        return class_name + "0";
    }

    public function ensureActorListByNameExists( class_name:String ) : Array<Actor> {
        if (!_actors_by_name.exists(class_name)) {
            _actors_by_name.set( class_name, [] );
        }
        return _actors_by_name.get(class_name);
    }

    public function count() {
        return _count;
    }
}
