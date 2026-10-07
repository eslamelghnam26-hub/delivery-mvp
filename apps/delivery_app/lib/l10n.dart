import 'package:flutter/material.dart';

class AppStrings {
  final String code;
  final Map<String, String> _src;

  const AppStrings._(this.code, this._src);

  static const Map<String, String> _ar = {
    'appName': 'خدماتي',
    'tagline': 'خدمات عند الطلب، من حولك',
    'login': 'تسجيل الدخول',
    'register': 'إنشاء حساب',
    'phone': 'رقم الهاتف',
    'password': 'كلمة المرور',
    'name': 'الاسم',
    'iAmProvider': 'أنا مقدم خدمة',
    'iAmCustomer': 'أنا عميل',
    'noAccount': 'ليس لديك حساب؟',
    'haveAccount': 'لديك حساب بالفعل؟',
    'logout': 'تسجيل الخروج',
    'services': 'الخدمات المتاحة',
    'newOrder': 'طلب جديد',
    'myOrders': 'طلباتي',
    'orderHistory': 'حسابي',
    'home': 'الرئيسية',
    'orders': 'الطلبات',
    'profile': 'الملف الشخصي',
    'address': 'العنوان',
    'description': 'تفاصيل المشكلة / ملاحظات',
    'location': 'الموقع',
    'useMyLocation': 'استخدم موقعي الحالي (جرّب في الإعداد)',
    'sendRequest': 'إرسال الطلب',
    'pending': 'قيد الانتظار',
    'accepted': 'تم القبول',
    'onTheWay': 'في الطريق',
    'inService': 'جارِ التنفيذ',
    'completed': 'مكتمل',
    'rejected': 'مرفوض',
    'canceled': 'ملغي',
    'availableOrders': 'طلبات متاحة',
    'myJobs': 'مهامي',
    'accept': 'قبول',
    'goAvailable': 'ابدأ الخدمة (متاح)',
    'goOffline': 'أنهِ الخدمة (غير متاح)',
    'cancelOrder': 'إلغاء الطلب',
    'rateOrder': 'تقييم الطلب',
    'rateProvider': 'قيّم مقدم الخدمة',
    'saved': 'تم الحفظ',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'الإنجليزية',
    'french': 'الفرنسية',
    'spanish': 'الإسبانية',
    'chooseLanguage': 'اختر اللغة',
    'errorOccurred': 'حدث خطأ',
    'statusUpdated': 'تم تحديث الحالة',
    'orderCreated': 'تم إنشاء الطلب',
    'orderCanceled': 'تم إلغاء الطلب',
    'noOrdersYet': 'لا توجد طلبات بعد',
    'chooseService': 'اختر الخدمة',
    'fresh': 'حديث',
    'locationFetchHint': 'الموقع التجريبي (30.044, 31.236) — وعن بعد على الجهاز الحقيقي يعمل GPS التلقائي',
    'selectServiceFirst': 'اختر الخدمة أولاً',
    'requiresService': 'الخدمة + الموقع مطلوبان للطلب',
    'orderNoLabel': 'رقم الطلب',
    'providerLiveLocation': 'موقع مقدم الخدمة الحي',
    'openInMaps': 'فتح في الخرائط',
  };

  static const Map<String, String> _en = {
    'appName': 'Khadamaty',
    'tagline': 'On-demand services around you',
    'login': 'Login',
    'register': 'Create account',
    'phone': 'Phone',
    'password': 'Password',
    'name': 'Name',
    'iAmProvider': 'I am a provider',
    'iAmCustomer': 'I am a customer',
    'noAccount': 'No account yet?',
    'haveAccount': 'Already have an account?',
    'logout': 'Logout',
    'services': 'Available services',
    'newOrder': 'New order',
    'myOrders': 'My orders',
    'orderHistory': 'Account',
    'home': 'Home',
    'orders': 'Orders',
    'profile': 'Profile',
    'address': 'Address',
    'description': 'Details / notes',
    'location': 'Location',
    'useMyLocation': 'Use my current location (try in settings)',
    'sendRequest': 'Send request',
    'pending': 'Pending',
    'accepted': 'Accepted',
    'onTheWay': 'On the way',
    'inService': 'In service',
    'completed': 'Completed',
    'rejected': 'Rejected',
    'canceled': 'Canceled',
    'availableOrders': 'Available orders',
    'myJobs': 'My jobs',
    'accept': 'Accept',
    'goAvailable': 'Go online',
    'goOffline': 'Go offline',
    'cancelOrder': 'Cancel order',
    'rateOrder': 'Rate order',
    'rateProvider': 'Rate the provider',
    'saved': 'Saved',
    'language': 'Language',
    'arabic': 'Arabic',
    'english': 'English',
    'french': 'French',
    'spanish': 'Spanish',
    'chooseLanguage': 'Choose language',
    'errorOccurred': 'An error occurred',
    'statusUpdated': 'Status updated',
    'orderCreated': 'Order created',
    'orderCanceled': 'Order canceled',
    'noOrdersYet': 'No orders yet',
    'chooseService': 'Choose service',
    'fresh': 'Latest',
    'locationFetchHint': 'Demo location (30.044, 31.236)',
    'selectServiceFirst': 'Select a service first',
    'requiresService': 'Service + location are required',
    'orderNoLabel': 'Order no.',
    'providerLiveLocation': 'Provider live location',
    'openInMaps': 'Open in maps',
  };

  static const Map<String, String> _fr = {
    'appName': 'Khadamaty',
    'tagline': 'Services à la demande, autour de vous',
    'login': 'Connexion',
    'register': 'Créer un compte',
    'phone': 'Téléphone',
    'password': 'Mot de passe',
    'name': 'Nom',
    'iAmProvider': 'Je suis un prestataire',
    'iAmCustomer': 'Je suis un client',
    'noAccount': 'Pas de compte ?',
    'haveAccount': 'Déjà un compte ?',
    'logout': 'Déconnexion',
    'services': 'Services disponibles',
    'newOrder': 'Nouvelle commande',
    'myOrders': 'Mes commandes',
    'orderHistory': 'Compte',
    'home': 'Accueil',
    'orders': 'Commandes',
    'profile': 'Profil',
    'address': 'Adresse',
    'description': 'Détails / notes',
    'location': 'Localisation',
    'useMyLocation': 'Utiliser ma position actuelle',
    'sendRequest': 'Envoyer la demande',
    'pending': 'En attente',
    'accepted': 'Acceptée',
    'onTheWay': 'En route',
    'inService': 'En cours',
    'completed': 'Terminée',
    'rejected': 'Refusée',
    'canceled': 'Annulée',
    'availableOrders': 'Commandes disponibles',
    'myJobs': 'Mes missions',
    'accept': 'Accepter',
    'goAvailable': 'Devenir disponible',
    'goOffline': 'Devenir indisponible',
    'cancelOrder': 'Annuler la commande',
    'rateOrder': 'Évaluer la commande',
    'rateProvider': 'Évaluer le prestataire',
    'saved': 'Enregistré',
    'language': 'Langue',
    'arabic': 'Arabe',
    'english': 'Anglais',
    'french': 'Français',
    'spanish': 'Espagnol',
    'chooseLanguage': 'Choisissez la langue',
    'errorOccurred': 'Une erreur est survenue',
    'statusUpdated': 'Statut mis à jour',
    'orderCreated': 'Commande créée',
    'orderCanceled': 'Commande annulée',
    'noOrdersYet': 'Aucune commande pour le moment',
    'chooseService': 'Choisir un service',
    'fresh': 'Récent',
    'locationFetchHint': 'Localisation démo (30.044, 31.236) — sur un vrai appareil, GPS automatique',
    'selectServiceFirst': 'Choisissez d\'abord un service',
    'requiresService': 'Service + localisation requis pour commander',
    'orderNoLabel': 'Commande n°',
    'providerLiveLocation': 'Position en direct du prestataire',
    'openInMaps': 'Ouvrir dans Maps',
  };

  static const Map<String, String> _es = {
    'appName': 'Khadamaty',
    'tagline': 'Servicios a la demanda, cerca de ti',
    'login': 'Iniciar sesión',
    'register': 'Crear cuenta',
    'phone': 'Teléfono',
    'password': 'Contraseña',
    'name': 'Nombre',
    'iAmProvider': 'Soy un proveedor',
    'iAmCustomer': 'Soy un cliente',
    'noAccount': '¿No tienes cuenta?',
    'haveAccount': '¿Ya tienes cuenta?',
    'logout': 'Cerrar sesión',
    'services': 'Servicios disponibles',
    'newOrder': 'Nueva solicitud',
    'myOrders': 'Mis solicitudes',
    'orderHistory': 'Cuenta',
    'home': 'Inicio',
    'orders': 'Solicitudes',
    'profile': 'Perfil',
    'address': 'Dirección',
    'description': 'Detalles / notas',
    'location': 'Ubicación',
    'useMyLocation': 'Usar mi ubicación actual',
    'sendRequest': 'Enviar solicitud',
    'pending': 'Pendiente',
    'accepted': 'Aceptada',
    'onTheWay': 'En camino',
    'inService': 'En curso',
    'completed': 'Completada',
    'rejected': 'Rechazada',
    'canceled': 'Cancelada',
    'availableOrders': 'Solicitudes disponibles',
    'myJobs': 'Mis trabajos',
    'accept': 'Aceptar',
    'goAvailable': 'Disponible',
    'goOffline': 'Indisponible',
    'cancelOrder': 'Cancelar solicitud',
    'rateOrder': 'Calificar solicitud',
    'rateProvider': 'Calificar al proveedor',
    'saved': 'Guardado',
    'language': 'Idioma',
    'arabic': 'Árabe',
    'english': 'Inglés',
    'french': 'Francés',
    'spanish': 'Español',
    'chooseLanguage': 'Elegir idioma',
    'errorOccurred': 'Ocurrió un error',
    'statusUpdated': 'Estado actualizado',
    'orderCreated': 'Solicitud creada',
    'orderCanceled': 'Solicitud cancelada',
    'noOrdersYet': 'Aún no hay solicitudes',
    'chooseService': 'Elegir servicio',
    'fresh': 'Recientes',
    'locationFetchHint': 'Ubicación demo (30.044, 31.236) — en un dispositivo real, GPS automático',
    'selectServiceFirst': 'Elige primero un servicio',
    'requiresService': 'Servicio + ubicación requeridos para solicitar',
    'orderNoLabel': 'Solicitud n.º',
    'providerLiveLocation': 'Ubicación en vivo del proveedor',
    'openInMaps': 'Abrir en Maps',
  };

  static AppStrings of(BuildContext context) {
    final code = Localizations.maybeLocaleOf(context)?.languageCode ?? 'ar';
    return fromCode(code);
  }

  static AppStrings fromCode(String code) => AppStrings._(
        code,
        switch (code) {
          'en' => _en,
          'fr' => _fr,
          'es' => _es,
          _ => _ar,
        },
      );

  String _g(String k) => _src[k] ?? _en[k] ?? k;

  bool get ar => code == 'ar';

  String get appName => _g('appName');
  String get tagline => _g('tagline');
  String get login => _g('login');
  String get register => _g('register');
  String get phone => _g('phone');
  String get password => _g('password');
  String get name => _g('name');
  String get iAmProvider => _g('iAmProvider');
  String get iAmCustomer => _g('iAmCustomer');
  String get noAccount => _g('noAccount');
  String get haveAccount => _g('haveAccount');
  String get logout => _g('logout');
  String get services => _g('services');
  String get newOrder => _g('newOrder');
  String get myOrders => _g('myOrders');
  String get orderHistory => _g('orderHistory');
  String get home => _g('home');
  String get orders => _g('orders');
  String get profile => _g('profile');
  String get address => _g('address');
  String get description => _g('description');
  String get location => _g('location');
  String get useMyLocation => _g('useMyLocation');
  String get sendRequest => _g('sendRequest');
  String get pending => _g('pending');
  String get accepted => _g('accepted');
  String get onTheWay => _g('onTheWay');
  String get inService => _g('inService');
  String get completed => _g('completed');
  String get rejected => _g('rejected');
  String get canceled => _g('canceled');
  String get availableOrders => _g('availableOrders');
  String get myJobs => _g('myJobs');
  String get accept => _g('accept');
  String get goAvailable => _g('goAvailable');
  String get goOffline => _g('goOffline');
  String get cancelOrder => _g('cancelOrder');
  String get rateOrder => _g('rateOrder');
  String get rateProvider => _g('rateProvider');
  String get saved => _g('saved');
  String get language => _g('language');
  String get arabic => _g('arabic');
  String get english => _g('english');
  String get french => _g('french');
  String get spanish => _g('spanish');
  String get chooseLanguage => _g('chooseLanguage');
  String get errorOccurred => _g('errorOccurred');
  String get statusUpdated => _g('statusUpdated');
  String get orderCreated => _g('orderCreated');
  String get orderCanceled => _g('orderCanceled');
  String get noOrdersYet => _g('noOrdersYet');
  String get chooseService => _g('chooseService');
  String get fresh => _g('fresh');
  String get locationFetchHint => _g('locationFetchHint');
  String get selectServiceFirst => _g('selectServiceFirst');
  String get requiresService => _g('requiresService');
  String get orderNoLabel => _g('orderNoLabel');
  String get providerLiveLocation => _g('providerLiveLocation');
  String get openInMaps => _g('openInMaps');
}