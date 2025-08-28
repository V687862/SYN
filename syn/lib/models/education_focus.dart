// lib/models/education_focus.dart

enum EducationFocus {
  study,
  athletics,
  social,
  work,
  skip,
}

String educationFocusLabel(EducationFocus f) {
  switch (f) {
    case EducationFocus.study: return 'Study';
    case EducationFocus.athletics: return 'Athletics';
    case EducationFocus.social: return 'Social';
    case EducationFocus.work: return 'Work';
    case EducationFocus.skip: return 'Skip';
  }
}

