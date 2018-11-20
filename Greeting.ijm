// @String name
// @OUTPUT String greeting

// An ImageJ macro with parameters.
// It is the duty of the scripting framework to harvest
// the 'name' parameter from the user, and then display
// the 'greeting' output parameter, based on its type.

greeting = "Hello " + name + "!";
i=1;
for (j=1;j<3;j++){
	print(greeting,j);
}
print(i);

