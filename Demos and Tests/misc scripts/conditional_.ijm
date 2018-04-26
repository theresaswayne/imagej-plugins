// @String instructor

if (getBoolean("Is " + instructor + " going too fast?")) {
    hint = "Tell them to to slow down!";
}
else {
    hint = "Try to modify the code, play with it...";
}
showMessage("Advice:", hint);