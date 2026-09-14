/// Central UI strings. Keeps copy in one place so it is easy to update
/// and ready for localization later.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Flutter LMS';

  // Auth
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String verifyEmail = 'Verify Email';
  static const String resendOtp = 'Resend OTP';
  static const String enterOtp = 'Enter the 6-digit code sent to your email';

  static const String loginAsStudent = 'Login as Student';
  static const String loginAsInstructor = 'Login as Instructor';
  static const String loginAsAdmin = 'Login as Admin';

  // Roles
  static const String student = 'Student';
  static const String instructor = 'Instructor';
  static const String admin = 'Admin';

  // Common actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String update = 'Update';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String apply = 'Apply';
  static const String clear = 'Clear';
  static const String confirm = 'Confirm';
  static const String close = 'Close';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String continueLabel = 'Continue';
  static const String seeAll = 'See all';

  // Empty / error states
  static const String somethingWentWrong = 'Something went wrong';
  static const String noDataFound = 'No data found';
  static const String noInternet = 'No internet connection';

  // Confirmations
  static const String areYouSure = 'Are you sure?';
  static const String thisActionCannotBeUndone =
      'This action cannot be undone.';

  // Student
  static const String dashboard = 'Dashboard';
  static const String home = 'Home';
  static const String courses = 'Courses';
  static const String myLearning = 'My Learning';
  static const String notifications = 'Notifications';
  static const String profile = 'Profile';
  static const String assignments = 'Assignments';
  static const String quizzes = 'Quizzes';
  static const String reviews = 'Reviews';
  static const String account = 'Account';
  static const String changePassword = 'Change Password';
  static const String editProfile = 'Edit Profile';

  // Instructor
  static const String learners = 'Learners';
  static const String createCourse = 'Create Course';
  static const String editCourse = 'Edit Course';
  static const String sections = 'Sections';
  static const String lessons = 'Lessons';
  static const String submissions = 'Submissions';

  // Admin
  static const String users = 'Users';
  static const String categories = 'Categories';
  static const String enrollments = 'Enrollments';

  // Status labels
  static const String draft = 'Draft';
  static const String published = 'Published';
  static const String archived = 'Archived';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String suspended = 'Suspended';
  static const String pending = 'Pending';
  static const String submitted = 'Submitted';
  static const String graded = 'Graded';
  static const String resubmissionRequired = 'Resubmission Required';
}