package com.findawalk;

import com.googlecode.objectify.Objectify;
import com.googlecode.objectify.ObjectifyFactory;

public class OfyService {
    static {
    	factory().register(Dog.class);
    	factory().register(DogOwner.class);
    	factory().register(Walk.class);
    }

    public static Objectify ofy() {
        return com.googlecode.objectify.ObjectifyService.ofy();
    }

    public static ObjectifyFactory factory() {
        return com.googlecode.objectify.ObjectifyService.factory();
    }
}