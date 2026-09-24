class AppLocalizations {
  AppLocalizations._();

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'navHome': 'Home', 'navAccounts': 'Accounts', 'navBudgets': 'Budgets', 'navMore': 'Others',
      'cashFlow': 'Cash Flow · This month', 'scheduled': 'Scheduled Transactions',
      'setABudget': 'Set a budget', 'overallBudget': 'MONTHLY BUDGET', 'limit': 'Limit:',
      'spent': 'spent', 'overBudget': 'Over Budget!', 'savingsGoal': 'Savings Goal',
      'progress': 'PROGRESS', 'saved': 'saved', 'completed': 'Complete',
      'setTarget': 'Savings Target', 'currentSavings': 'Current Savings',
      'addTransaction': 'Add Transaction', 'expense': 'Expense', 'income': 'Income',
      'save': 'Save', 'cancel': 'Cancel', 'delete': 'Delete',
      'deleteTransactionTitle': 'Delete transaction?', 'deleteTransactionBody': "This can't be undone.",
      'language': 'Language', 'appearance': 'Appearance', 'darkMode': 'Dark Mode',
    },
    'id': {
      'navHome': 'Beranda', 'navAccounts': 'Akun', 'navBudgets': 'Anggaran', 'navMore': 'Lainnya',
      'cashFlow': 'Arus Kas · Bulan ini', 'scheduled': 'Transaksi Terjadwal',
      'setABudget': 'Atur anggaran', 'overallBudget': 'ANGGARAN BULANAN', 'limit': 'Batas:',
      'spent': 'terpakai', 'overBudget': 'Melebihi Anggaran!', 'savingsGoal': 'Target Tabungan',
      'progress': 'PROGRES', 'saved': 'ditabung', 'completed': 'Selesai',
      'setTarget': 'Target Tabungan', 'currentSavings': 'Tabungan Sekarang',
      'addTransaction': 'Tambah Transaksi', 'expense': 'Pengeluaran', 'income': 'Pemasukan',
      'save': 'Simpan', 'cancel': 'Batal', 'delete': 'Hapus',
      'deleteTransactionTitle': 'Hapus transaksi?', 'deleteTransactionBody': 'Tindakan ini tidak dapat dibatalkan.',
      'language': 'Bahasa', 'appearance': 'Tampilan', 'darkMode': 'Mode Gelap',
    },
    'fr': {
      'navHome': 'Accueil', 'navAccounts': 'Comptes', 'navBudgets': 'Budgets', 'navMore': 'Autres',
      'cashFlow': 'Flux de trésorerie · Ce mois-ci', 'scheduled': 'Transactions planifiées',
      'setABudget': 'Définir un budget', 'overallBudget': 'BUDGET MENSUEL', 'limit': 'Limite :',
      'spent': 'dépensé', 'overBudget': 'Dépassement !', 'savingsGoal': "Objectif d'Épargne",
      'progress': 'PROGRESSION', 'saved': 'épargné', 'completed': 'Complété',
      'setTarget': "Objectif d'Épargne", 'currentSavings': 'Épargne Actuelle',
      'addTransaction': 'Ajouter Transaction', 'expense': 'Dépense', 'income': 'Revenu',
      'save': 'Enregistrer', 'cancel': 'Annuler', 'delete': 'Supprimer',
      'deleteTransactionTitle': 'Supprimer la transaction ?', 'deleteTransactionBody': 'Cette action est irréversible.',
      'language': 'Langue', 'appearance': 'Apparence', 'darkMode': 'Mode Sombre',
    },
  };

  static const Map<String, String> languageLabels = {
    'en': 'English', 'id': 'Indonesia', 'fr': 'Français',
  };

  static String t(String lang, String key) =>
      _strings[lang]?[key] ?? _strings['en']![key] ?? key;
}
