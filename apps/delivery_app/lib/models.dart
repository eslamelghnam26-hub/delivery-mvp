class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String lang;
  final int? serviceId;
  final String? bio;
  final double? rating;
  final int? jobsCount;
  final bool? isOnline;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.lang = 'ar',
    this.serviceId,
    this.bio,
    this.rating,
    this.jobsCount,
    this.isOnline,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as int,
        name: (j['name'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        email: j['email'] as String?,
        role: (j['role'] ?? 'customer') as String,
        lang: (j['lang'] ?? 'ar') as String,
        serviceId: j['service_id'] as int?,
        bio: j['bio'] as String?,
        rating: (j['rating'] as num?)?.toDouble(),
        jobsCount: j['jobs_count'] as int?,
        isOnline: j['is_online'] == null ? null : (j['is_online'] as int) == 1,
      );
}

class Service {
  final int id;
  final String nameAr;
  final String nameEn;
  final String icon;

  const Service({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon = 'misc',
  });

  factory Service.fromJson(Map<String, dynamic> j) => Service(
        id: j['id'] as int,
        nameAr: (j['name_ar'] ?? '') as String,
        nameEn: (j['name_en'] ?? '') as String,
        icon: (j['icon'] ?? 'misc') as String,
      );
}

class Order {
  final int id;
  final String orderNo;
  final int customerId;
  final int? providerId;
  final int serviceId;
  final double lat;
  final double lng;
  final String? address;
  final String? description;
  final String status;
  final int? customerRating;
  final int? providerRating;

  const Order({
    required this.id,
    required this.orderNo,
    required this.customerId,
    this.providerId,
    required this.serviceId,
    required this.lat,
    required this.lng,
    this.address,
    this.description,
    required this.status,
    this.customerRating,
    this.providerRating,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as int,
        orderNo: (j['order_no'] ?? '') as String,
        customerId: j['customer_id'] as int,
        providerId: j['provider_id'] as int?,
        serviceId: j['service_id'] as int,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        address: j['address'] as String?,
        description: j['description'] as String?,
        status: (j['status'] ?? 'pending') as String,
        customerRating: j['customer_rating'] as int?,
        providerRating: j['provider_rating'] as int?,
      );
}