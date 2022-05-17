// entry point
void main(){

  // using the Dog class - creating an instance of this class
  var myDog = Dog();

  // assigning values to the newly clreated instance
  myDog.breed = 'Poodle';
  myDog.name = 'Jack';
  myDog.color = 'Brown';

  // displaying the values on the console
  print(myDog.breed);
  print(myDog.name);
  print(myDog.color);
}

// Dog class
class Dog{

  // class properties
  String? breed;
  String? name;
  String? color;
}