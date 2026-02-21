class FormValidation {
 
static String? emailValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Email cannot be empty';
  }
 
  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}
//////////////////////////////
static String? passwordValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password cannot be empty';
  } else if (value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}
///////////////////////////////
static String? confirmPasswordValidation(String? value, String password) {
  if (value == null || value.isEmpty) {
    return 'Confirm password cannot be empty';
  }
  if (value != password) {
    return 'Passwords do not match';
  }
  return null;
}
//////////////////////////
static String? nameBloodValidation(String? value) {
  if (value == null || value.isEmpty) {
    return 'field cannot be empty';
  }
  return null; 
}



}