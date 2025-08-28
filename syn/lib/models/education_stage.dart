// lib/models/education_stage.dart

// Enum to represent generic education stages.
enum EducationStage {
  none, // Not currently enrolled or before starting school
  preschool,
  elementarySchool, // Approx ages 6-10
  middleSchool,     // Approx ages 11-13
  highSchool,       // Approx ages 14-17/18
  vocationalTraining, // Alternative to or after high school
  universityBachelor,
  universityMaster,
  universityDoctorate,
  graduatedHighSchool, // Intermediate state if not pursuing further ed immediately
  graduatedUniversityBachelor,
  graduatedUniversityMaster,
  graduatedUniversityDoctorate,
 }

// Helper to get a display-friendly name for the stage
String educationStageToString(EducationStage stage) {
  switch (stage) {
    case EducationStage.none:
      return "Not Enrolled";
    case EducationStage.preschool:
      return "Preschool";
    case EducationStage.elementarySchool:
      return "Elementary School";
    case EducationStage.middleSchool:
      return "Middle School";
    case EducationStage.highSchool:
      return "High School";
    case EducationStage.vocationalTraining:
      return "Vocational Training";
    case EducationStage.universityBachelor:
      return "University (Bachelor's)";
    case EducationStage.universityMaster:
      return "University (Master's)";
    case EducationStage.universityDoctorate:
      return "University (Doctorate)";
    case EducationStage.graduatedHighSchool:
      return "High School Graduate";
    case EducationStage.graduatedUniversityBachelor:
      return "University Graduate (Bachelor's)";
    case EducationStage.graduatedUniversityMaster:
      return "University Graduate (Master's)";
    case EducationStage.graduatedUniversityDoctorate:
      return "University Graduate (Doctorate)";
  }
}