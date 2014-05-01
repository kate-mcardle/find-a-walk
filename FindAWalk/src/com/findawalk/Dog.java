package com.findawalk;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;

@Entity
public class Dog {
	@Id
	public Long id;
	public String name;
	public String kind;
	public int age;
	public String gender;
	public int weight;
	
	public Dog() {
	}

	public Dog(String name, String kind, int age, String gender, int weight) {
		this.name = name;
		this.kind = kind;
		this.age = age;
		this.gender = gender;
		this.weight = weight;
	}
}
