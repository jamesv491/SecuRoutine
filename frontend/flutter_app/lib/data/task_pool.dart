// Central pool of cybersecurity tasks used for daily task generation.
// Each task belongs to a category matching one of the four
// security_preference values chosen during profile setup.
const List<Map<String, dynamic>> taskPool = [
  // Password Security
  {
    'id': 'ps1',
    'name': 'Change an old password',
    'description': 'Update one password that has not been changed recently.',
    'points': 10,
    'category': 'Password Security',
  },
  {
    'id': 'ps2',
    'name': 'Check password strength',
    'description': 'Review one saved password and make it longer or more unique.',
    'points': 8,
    'category': 'Password Security',
  },
  {
    'id': 'ps3',
    'name': 'Remove a duplicate password',
    'description':
        'Find one account reusing a password from another account and change it.',
    'points': 12,
    'category': 'Password Security',
  },
  {
    'id': 'ps4',
    'name': 'Check for password breach',
    'description':
        'Using online tools such as HaveIBeenPwned (for example) check your passwords for any sign of breaches',
    'points': 10,
    'category': 'Password Security',
  },
  {
    'id': 'ps5',
    'name': 'Test password cracking time',
    'description':
        'Use an free tool online to check the time it takes to crack your password. Update if necessary.',
    'points': 12,
    'category': 'Password Security',
  },

  // Two-Factor Authentication
  {
    'id': 'tfa1',
    'name': 'Enable two-factor authentication',
    'description': 'Turn on 2FA for one account that does not have it enabled yet.',
    'points': 15,
    'category': 'Two-Factor Authentication',
  },
  {
    'id': 'tfa2',
    'name': 'Review your 2FA methods',
    'description': 'Check which accounts already have 2FA and note which do not.',
    'points': 8,
    'category': 'Two-Factor Authentication',
  },
  {
    'id': 'tfa3',
    'name': 'Back up your recovery codes',
    'description': 'Make sure your 2FA recovery codes are saved somewhere safe.',
    'points': 10,
    'category': 'Two-Factor Authentication',
  },
  {
    'id': 'tfa4',
    'name': ' Transition from SMS to Hardware/App 2FA',
    'description': 'If you recieve SMS messages to login change it to a app-based token authenticator. (Microsoft, Proton, etc)',
    'points': 12,
    'category': 'Two-Factor Authentication',
  },
  {
    'id': 'tfa5',
    'name': 'Passkey Implementation for passwords',
    'description': 'Search online and determine if you want to switch to passkeys or retain your passwords which you have to remember!',
    'points': 12,
    'category': 'Two-Factor Authentication',
  },

  // Account Monitoring
  {
    'id': 'am1',
    'name': 'Review recent login activity',
    'description': 'Check whether recent sign in activity looks normal.',
    'points': 13,
    'category': 'Account Monitoring',
  },
  {
    'id': 'am2',
    'name': 'Review privacy settings',
    'description': 'Check privacy permissions on your main account.',
    'points': 10,
    'category': 'Account Monitoring',
  },
  {
    'id': 'am3',
    'name': 'Check connected third-party apps',
    'description':
        'Review which apps have access to your account and remove any you no longer use.',
    'points': 12,
    'category': 'Account Monitoring',
  },
   {
    'id': 'am4',
    'name': 'Have account security reviewed by F&F (Friends and family)',
    'description':
        'Ask a family member or close friend for their opinion on how to increase your account security.',
    'points': 10,
    'category': 'Account Monitoring',
  },
  {
    'id': 'am5',
    'name': 'Review Account changes',
    'description':
        'Create and maintain a personal "account inventory" spreadsheet listing all important accounts with their last review date and security status.',
    'points': 10,
    'category': 'Account Monitoring',
  },


  // Phishing Awareness
  {
    'id': 'pa1',
    'name': 'Spot a phishing email',
    'description':
        'Look through your inbox for one suspicious email and check its sender address.',
    'points': 10,
    'category': 'Phishing Awareness',
  },
  {
    'id': 'pa2',
    'name': 'Verify a suspicious link',
    'description':
        'Practice hovering over a link before clicking to check the destination URL AKA where it actually leads.',
    'points': 8,
    'category': 'Phishing Awareness',
  },
  {
    'id': 'pa3',
    'name': 'Report a phishing attempt',
    'description':
        "Use your email provider's report tool on one suspicious message.",
    'points': 12,
    'category': 'Phishing Awareness',
  },
  {
    'id': 'pa4',
    'name': 'Learn about the dangers of Phishing',
    'description':
        "Using a reputable source like Microsoft, government websites, etc learn about the dangers of phishing and how to protect yourself.",
    'points': 10,
    'category': 'Phishing Awareness',
  },
];