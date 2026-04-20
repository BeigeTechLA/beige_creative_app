import 'dart:convert';

class ShootsModel {
  final bool error;
  final String message;
  final Data data;

  ShootsModel({
    required this.error,
    required this.message,
    required this.data,
  });

  factory ShootsModel.fromRawJson(String str) => ShootsModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootsModel.fromJson(Map<String, dynamic> json) => ShootsModel(
    error: json["error"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  final List<PendingRequestCard> pendingRequestCards;
  final List<AllShoot> allShoots;
  final List<PendingRequest> pendingRequests;
  final int equipmentRequests;

  Data({
    required this.pendingRequestCards,
    required this.allShoots,
    required this.pendingRequests,
    required this.equipmentRequests,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pendingRequestCards: List<PendingRequestCard>.from(json["pendingRequestCards"].map((x) => PendingRequestCard.fromJson(x))),
    allShoots: List<AllShoot>.from(json["allShoots"].map((x) => AllShoot.fromJson(x))),
    pendingRequests: List<PendingRequest>.from(json["pendingRequests"].map((x) => PendingRequest.fromJson(x))),
    equipmentRequests: json["equipmentRequests"],
  );

  Map<String, dynamic> toJson() => {
    "pendingRequestCards": List<dynamic>.from(pendingRequestCards.map((x) => x.toJson())),
    "allShoots": List<dynamic>.from(allShoots.map((x) => x.toJson())),
    "pendingRequests": List<dynamic>.from(pendingRequests.map((x) => x.toJson())),
    "equipmentRequests": equipmentRequests,
  };
}

class AllShoot {
  final int id;
  final int projectId;
  final int crewMemberId;
  final DateTime assignedDate;
  final String status;
  final int organizationType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int crewAccept;
  final DateTime respondedAt;
  final int? roleId;
  final DateTime? eventDate;
  final String? startTime;
  final String? endTime;
  final dynamic expiresAt;
  final AllShootProject project;

  AllShoot({
    required this.id,
    required this.projectId,
    required this.crewMemberId,
    required this.assignedDate,
    required this.status,
    required this.organizationType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.crewAccept,
    required this.respondedAt,
    required this.roleId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.expiresAt,
    required this.project,
  });

  factory AllShoot.fromRawJson(String str) => AllShoot.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AllShoot.fromJson(Map<String, dynamic> json) => AllShoot(
    id: json["id"],
    projectId: json["project_id"],
    crewMemberId: json["crew_member_id"],
    assignedDate: DateTime.parse(json["assigned_date"]),
    status: json["status"],
    organizationType: json["organization_type"],
    isActive: json["is_active"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    crewAccept: json["crew_accept"],
    respondedAt: DateTime.parse(json["responded_at"]),
    roleId: json["role_id"],
    eventDate: json["event_date"] == null ? null : DateTime.parse(json["event_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    expiresAt: json["expires_at"],
    project: AllShootProject.fromJson(json["project"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "project_id": projectId,
    "crew_member_id": crewMemberId,
    "assigned_date": assignedDate.toIso8601String(),
    "status": status,
    "organization_type": organizationType,
    "is_active": isActive,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "crew_accept": crewAccept,
    "responded_at": respondedAt.toIso8601String(),
    "role_id": roleId,
    "event_date": "${eventDate!.year.toString().padLeft(4, '0')}-${eventDate!.month.toString().padLeft(2, '0')}-${eventDate!.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "expires_at": expiresAt,
    "project": project.toJson(),
  };
}

class AllShootProject {
  final int durationHours;
  final dynamic videoEditTypes;
  final dynamic photoEditTypes;
  final int streamProjectBookingId;
  final int? clientUserId;
  final dynamic selectedCreativeUserId;
  final dynamic selectedCreatives;
  final int? specialtyId;
  final int? shootTypeId;
  final String shootType;
  final dynamic deliverableOption;
  final dynamic serviceType;
  final String? editTypes;
  final String projectName;
  final String? description;
  final dynamic referenceLink;
  final dynamic notes;
  final String referenceLinks;
  final String? additionalDetails;
  final String? eventType;
  final String contentType;
  final DateTime eventDate;
  final bool editsNeeded;
  final String startTime;
  final String endTime;
  final dynamic budget;
  final dynamic budgetMin;
  final dynamic budgetMax;
  final dynamic expectedViewers;
  final dynamic streamQuality;
  final int? crewSizeNeeded;
  final dynamic recommendedCrewSize;
  final String eventLocation;
  final dynamic eventLatitude;
  final dynamic eventLongitude;
  final String streamingPlatforms;
  final String crewRoles;
  final dynamic skillsNeeded;
  final dynamic equipmentsNeeded;
  final bool isDraft;
  final bool isCompleted;
  final bool isCancelled;
  final bool isActive;
  final int bookingStatus;
  final int? creativeUserId;
  final int paymentStatus;
  final String? paymentMethod;
  final String? confirmationNumber;
  final String? transactionId;
  final String? paidAmount;
  final DateTime? paidAt;
  final bool payFullInAdvance;
  final dynamic clientNotes;
  final int earlyBirdDiscountPct;
  final String baseAmount;
  final String addonsAmount;
  final String discountAmount;
  final String totalAmount;
  final dynamic paymentReference;
  final DateTime createdAt;
  final String? crewRequirements;
  final dynamic clientFullName;
  final dynamic clientEmail;
  final dynamic clientPhone;
  final ShootTypeMaster? shootTypeMaster;

  AllShootProject({
    required this.durationHours,
    required this.videoEditTypes,
    required this.photoEditTypes,
    required this.streamProjectBookingId,
    required this.clientUserId,
    required this.selectedCreativeUserId,
    required this.selectedCreatives,
    required this.specialtyId,
    required this.shootTypeId,
    required this.shootType,
    required this.deliverableOption,
    required this.serviceType,
    required this.editTypes,
    required this.projectName,
    required this.description,
    required this.referenceLink,
    required this.notes,
    required this.referenceLinks,
    required this.additionalDetails,
    required this.eventType,
    required this.contentType,
    required this.eventDate,
    required this.editsNeeded,
    required this.startTime,
    required this.endTime,
    required this.budget,
    required this.budgetMin,
    required this.budgetMax,
    required this.expectedViewers,
    required this.streamQuality,
    required this.crewSizeNeeded,
    required this.recommendedCrewSize,
    required this.eventLocation,
    required this.eventLatitude,
    required this.eventLongitude,
    required this.streamingPlatforms,
    required this.crewRoles,
    required this.skillsNeeded,
    required this.equipmentsNeeded,
    required this.isDraft,
    required this.isCompleted,
    required this.isCancelled,
    required this.isActive,
    required this.bookingStatus,
    required this.creativeUserId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.confirmationNumber,
    required this.transactionId,
    required this.paidAmount,
    required this.paidAt,
    required this.payFullInAdvance,
    required this.clientNotes,
    required this.earlyBirdDiscountPct,
    required this.baseAmount,
    required this.addonsAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentReference,
    required this.createdAt,
    required this.crewRequirements,
    required this.clientFullName,
    required this.clientEmail,
    required this.clientPhone,
    required this.shootTypeMaster,
  });

  factory AllShootProject.fromRawJson(String str) => AllShootProject.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AllShootProject.fromJson(Map<String, dynamic> json) => AllShootProject(
    durationHours: json["duration_hours"],
    videoEditTypes: json["video_edit_types"],
    photoEditTypes: json["photo_edit_types"],
    streamProjectBookingId: json["stream_project_booking_id"],
    clientUserId: json["client_user_id"],
    selectedCreativeUserId: json["selected_creative_user_id"],
    selectedCreatives: json["selected_creatives"],
    specialtyId: json["specialty_id"],
    shootTypeId: json["shoot_type_id"],
    shootType: json["shoot_type"],
    deliverableOption: json["deliverable_option"],
    serviceType: json["service_type"],
    editTypes: json["edit_types"],
    projectName: json["project_name"],
    description: json["description"],
    referenceLink: json["reference_link"],
    notes: json["notes"],
    referenceLinks: json["reference_links"],
    additionalDetails: json["additional_details"],
    eventType: json["event_type"],
    contentType: json["content_type"],
    eventDate: DateTime.parse(json["event_date"]),
    editsNeeded: json["edits_needed"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    budget: json["budget"],
    budgetMin: json["budget_min"],
    budgetMax: json["budget_max"],
    expectedViewers: json["expected_viewers"],
    streamQuality: json["stream_quality"],
    crewSizeNeeded: json["crew_size_needed"],
    recommendedCrewSize: json["recommended_crew_size"],
    eventLocation: json["event_location"],
    eventLatitude: json["event_latitude"],
    eventLongitude: json["event_longitude"],
    streamingPlatforms: json["streaming_platforms"],
    crewRoles: json["crew_roles"],
    skillsNeeded: json["skills_needed"],
    equipmentsNeeded: json["equipments_needed"],
    isDraft: json["is_draft"],
    isCompleted: json["is_completed"],
    isCancelled: json["is_cancelled"],
    isActive: json["is_active"],
    bookingStatus: json["booking_status"],
    creativeUserId: json["creative_user_id"],
    paymentStatus: json["payment_status"],
    paymentMethod: json["payment_method"],
    confirmationNumber: json["confirmation_number"],
    transactionId: json["transaction_id"],
    paidAmount: json["paid_amount"],
    paidAt: json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
    payFullInAdvance: json["pay_full_in_advance"],
    clientNotes: json["client_notes"],
    earlyBirdDiscountPct: json["early_bird_discount_pct"],
    baseAmount: json["base_amount"],
    addonsAmount: json["addons_amount"],
    discountAmount: json["discount_amount"],
    totalAmount: json["total_amount"],
    paymentReference: json["payment_reference"],
    createdAt: DateTime.parse(json["created_at"]),
    crewRequirements: json["crew_requirements"],
    clientFullName: json["client_full_name"],
    clientEmail: json["client_email"],
    clientPhone: json["client_phone"],
    shootTypeMaster: json["shoot_type_master"] == null ? null : ShootTypeMaster.fromJson(json["shoot_type_master"]),
  );

  Map<String, dynamic> toJson() => {
    "duration_hours": durationHours,
    "video_edit_types": videoEditTypes,
    "photo_edit_types": photoEditTypes,
    "stream_project_booking_id": streamProjectBookingId,
    "client_user_id": clientUserId,
    "selected_creative_user_id": selectedCreativeUserId,
    "selected_creatives": selectedCreatives,
    "specialty_id": specialtyId,
    "shoot_type_id": shootTypeId,
    "shoot_type": shootType,
    "deliverable_option": deliverableOption,
    "service_type": serviceType,
    "edit_types": editTypes,
    "project_name": projectName,
    "description": description,
    "reference_link": referenceLink,
    "notes": notes,
    "reference_links": referenceLinks,
    "additional_details": additionalDetails,
    "event_type": eventType,
    "content_type": contentType,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "edits_needed": editsNeeded,
    "start_time": startTime,
    "end_time": endTime,
    "budget": budget,
    "budget_min": budgetMin,
    "budget_max": budgetMax,
    "expected_viewers": expectedViewers,
    "stream_quality": streamQuality,
    "crew_size_needed": crewSizeNeeded,
    "recommended_crew_size": recommendedCrewSize,
    "event_location": eventLocation,
    "event_latitude": eventLatitude,
    "event_longitude": eventLongitude,
    "streaming_platforms": streamingPlatforms,
    "crew_roles": crewRoles,
    "skills_needed": skillsNeeded,
    "equipments_needed": equipmentsNeeded,
    "is_draft": isDraft,
    "is_completed": isCompleted,
    "is_cancelled": isCancelled,
    "is_active": isActive,
    "booking_status": bookingStatus,
    "creative_user_id": creativeUserId,
    "payment_status": paymentStatus,
    "payment_method": paymentMethod,
    "confirmation_number": confirmationNumber,
    "transaction_id": transactionId,
    "paid_amount": paidAmount,
    "paid_at": paidAt?.toIso8601String(),
    "pay_full_in_advance": payFullInAdvance,
    "client_notes": clientNotes,
    "early_bird_discount_pct": earlyBirdDiscountPct,
    "base_amount": baseAmount,
    "addons_amount": addonsAmount,
    "discount_amount": discountAmount,
    "total_amount": totalAmount,
    "payment_reference": paymentReference,
    "created_at": createdAt.toIso8601String(),
    "crew_requirements": crewRequirements,
    "client_full_name": clientFullName,
    "client_email": clientEmail,
    "client_phone": clientPhone,
    "shoot_type_master": shootTypeMaster?.toJson(),
  };
}

class ShootTypeMaster {
  final int shootTypeId;
  final String name;
  final String imageUrl;

  ShootTypeMaster({
    required this.shootTypeId,
    required this.name,
    required this.imageUrl,
  });

  factory ShootTypeMaster.fromRawJson(String str) => ShootTypeMaster.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ShootTypeMaster.fromJson(Map<String, dynamic> json) => ShootTypeMaster(
    shootTypeId: json["shoot_type_id"],
    name: json["name"],
    imageUrl: json["image_url"],
  );

  Map<String, dynamic> toJson() => {
    "shoot_type_id": shootTypeId,
    "name": name,
    "image_url": imageUrl,
  };
}

class PendingRequestCard {
  final int id;
  final int projectId;
  final int crewMemberId;
  final String projectName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String eventLocation;
  final String contentType;
  final int shootTypeId;
  final String shootType;
  final String shootTypeImageUrl;
  final String totalAmount;
  final dynamic budget;
  final String status;
  final int crewAccept;
  final Cta cta;

  PendingRequestCard({
    required this.id,
    required this.projectId,
    required this.crewMemberId,
    required this.projectName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.eventLocation,
    required this.contentType,
    required this.shootTypeId,
    required this.shootType,
    required this.shootTypeImageUrl,
    required this.totalAmount,
    required this.budget,
    required this.status,
    required this.crewAccept,
    required this.cta,
  });

  factory PendingRequestCard.fromRawJson(String str) => PendingRequestCard.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PendingRequestCard.fromJson(Map<String, dynamic> json) => PendingRequestCard(
    id: json["id"],
    projectId: json["project_id"],
    crewMemberId: json["crew_member_id"],
    projectName: json["project_name"],
    eventDate: DateTime.parse(json["event_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    eventLocation: json["event_location"],
    contentType: json["content_type"],
    shootTypeId: json["shoot_type_id"],
    shootType: json["shoot_type"],
    shootTypeImageUrl: json["shoot_type_image_url"],
    totalAmount: json["total_amount"],
    budget: json["budget"],
    status: json["status"],
    crewAccept: json["crew_accept"],
    cta: Cta.fromJson(json["cta"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "project_id": projectId,
    "crew_member_id": crewMemberId,
    "project_name": projectName,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "event_location": eventLocation,
    "content_type": contentType,
    "shoot_type_id": shootTypeId,
    "shoot_type": shootType,
    "shoot_type_image_url": shootTypeImageUrl,
    "total_amount": totalAmount,
    "budget": budget,
    "status": status,
    "crew_accept": crewAccept,
    "cta": cta.toJson(),
  };
}

class Cta {
  final String primary;
  final String secondary;

  Cta({
    required this.primary,
    required this.secondary,
  });

  factory Cta.fromRawJson(String str) => Cta.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cta.fromJson(Map<String, dynamic> json) => Cta(
    primary: json["primary"],
    secondary: json["secondary"],
  );

  Map<String, dynamic> toJson() => {
    "primary": primary,
    "secondary": secondary,
  };
}

class PendingRequest {
  final int id;
  final int projectId;
  final int crewMemberId;
  final DateTime assignedDate;
  final String status;
  final int organizationType;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int crewAccept;
  final dynamic respondedAt;
  final int roleId;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final dynamic expiresAt;
  final PendingRequestProject project;

  PendingRequest({
    required this.id,
    required this.projectId,
    required this.crewMemberId,
    required this.assignedDate,
    required this.status,
    required this.organizationType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.crewAccept,
    required this.respondedAt,
    required this.roleId,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.expiresAt,
    required this.project,
  });

  factory PendingRequest.fromRawJson(String str) => PendingRequest.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PendingRequest.fromJson(Map<String, dynamic> json) => PendingRequest(
    id: json["id"],
    projectId: json["project_id"],
    crewMemberId: json["crew_member_id"],
    assignedDate: DateTime.parse(json["assigned_date"]),
    status: json["status"],
    organizationType: json["organization_type"],
    isActive: json["is_active"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    crewAccept: json["crew_accept"],
    respondedAt: json["responded_at"] == null
        ? null
        : DateTime.parse(json["responded_at"]),
    roleId: json["role_id"],
    eventDate: DateTime.parse(json["event_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    expiresAt: json["expires_at"],
    project: PendingRequestProject.fromJson(json["project"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "project_id": projectId,
    "crew_member_id": crewMemberId,
    "assigned_date": assignedDate.toIso8601String(),
    "status": status,
    "organization_type": organizationType,
    "is_active": isActive,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "crew_accept": crewAccept,
    "responded_at": respondedAt,
    "role_id": roleId,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "start_time": startTime,
    "end_time": endTime,
    "expires_at": expiresAt,
    "project": project.toJson(),
  };
}

class PendingRequestProject {
  final int durationHours;
  final List<String> videoEditTypes;
  final List<String> photoEditTypes;
  final int streamProjectBookingId;
  final int clientUserId;
  final dynamic selectedCreativeUserId;
  final dynamic selectedCreatives;
  final int specialtyId;
  final int shootTypeId;
  final String shootType;
  final dynamic deliverableOption;
  final dynamic serviceType;
  final String editTypes;
  final String projectName;
  final dynamic description;
  final dynamic referenceLink;
  final dynamic notes;
  final String referenceLinks;
  final String additionalDetails;
  final dynamic eventType;
  final String contentType;
  final DateTime eventDate;
  final bool editsNeeded;
  final String startTime;
  final String endTime;
  final dynamic budget;
  final dynamic budgetMin;
  final dynamic budgetMax;
  final dynamic expectedViewers;
  final dynamic streamQuality;
  final dynamic crewSizeNeeded;
  final dynamic recommendedCrewSize;
  final String eventLocation;
  final dynamic eventLatitude;
  final dynamic eventLongitude;
  final String streamingPlatforms;
  final String crewRoles;
  final dynamic skillsNeeded;
  final dynamic equipmentsNeeded;
  final bool isDraft;
  final bool isCompleted;
  final bool isCancelled;
  final bool isActive;
  final int bookingStatus;
  final int creativeUserId;
  final int paymentStatus;
  final String paymentMethod;
  final String confirmationNumber;
  final String transactionId;
  final String paidAmount;
  final DateTime paidAt;
  final bool payFullInAdvance;
  final dynamic clientNotes;
  final int earlyBirdDiscountPct;
  final String baseAmount;
  final String addonsAmount;
  final String discountAmount;
  final String totalAmount;
  final dynamic paymentReference;
  final DateTime createdAt;
  final String crewRequirements;
  final dynamic clientFullName;
  final dynamic clientEmail;
  final dynamic clientPhone;
  final ShootTypeMaster shootTypeMaster;

  PendingRequestProject({
    required this.durationHours,
    required this.videoEditTypes,
    required this.photoEditTypes,
    required this.streamProjectBookingId,
    required this.clientUserId,
    required this.selectedCreativeUserId,
    required this.selectedCreatives,
    required this.specialtyId,
    required this.shootTypeId,
    required this.shootType,
    required this.deliverableOption,
    required this.serviceType,
    required this.editTypes,
    required this.projectName,
    required this.description,
    required this.referenceLink,
    required this.notes,
    required this.referenceLinks,
    required this.additionalDetails,
    required this.eventType,
    required this.contentType,
    required this.eventDate,
    required this.editsNeeded,
    required this.startTime,
    required this.endTime,
    required this.budget,
    required this.budgetMin,
    required this.budgetMax,
    required this.expectedViewers,
    required this.streamQuality,
    required this.crewSizeNeeded,
    required this.recommendedCrewSize,
    required this.eventLocation,
    required this.eventLatitude,
    required this.eventLongitude,
    required this.streamingPlatforms,
    required this.crewRoles,
    required this.skillsNeeded,
    required this.equipmentsNeeded,
    required this.isDraft,
    required this.isCompleted,
    required this.isCancelled,
    required this.isActive,
    required this.bookingStatus,
    required this.creativeUserId,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.confirmationNumber,
    required this.transactionId,
    required this.paidAmount,
    required this.paidAt,
    required this.payFullInAdvance,
    required this.clientNotes,
    required this.earlyBirdDiscountPct,
    required this.baseAmount,
    required this.addonsAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentReference,
    required this.createdAt,
    required this.crewRequirements,
    required this.clientFullName,
    required this.clientEmail,
    required this.clientPhone,
    required this.shootTypeMaster,
  });

  factory PendingRequestProject.fromRawJson(String str) => PendingRequestProject.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PendingRequestProject.fromJson(Map<String, dynamic> json) => PendingRequestProject(
    durationHours: json["duration_hours"],
    videoEditTypes: List<String>.from(json["video_edit_types"].map((x) => x)),
    photoEditTypes: List<String>.from(json["photo_edit_types"].map((x) => x)),
    streamProjectBookingId: json["stream_project_booking_id"],
    clientUserId: json["client_user_id"],
    selectedCreativeUserId: json["selected_creative_user_id"],
    selectedCreatives: json["selected_creatives"],
    specialtyId: json["specialty_id"],
    shootTypeId: json["shoot_type_id"],
    shootType: json["shoot_type"],
    deliverableOption: json["deliverable_option"],
    serviceType: json["service_type"],
    editTypes: json["edit_types"],
    projectName: json["project_name"],
    description: json["description"],
    referenceLink: json["reference_link"],
    notes: json["notes"],
    referenceLinks: json["reference_links"],
    additionalDetails: json["additional_details"],
    eventType: json["event_type"],
    contentType: json["content_type"],
    eventDate: DateTime.parse(json["event_date"]),
    editsNeeded: json["edits_needed"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    budget: json["budget"],
    budgetMin: json["budget_min"],
    budgetMax: json["budget_max"],
    expectedViewers: json["expected_viewers"],
    streamQuality: json["stream_quality"],
    crewSizeNeeded: json["crew_size_needed"],
    recommendedCrewSize: json["recommended_crew_size"],
    eventLocation: json["event_location"],
    eventLatitude: json["event_latitude"],
    eventLongitude: json["event_longitude"],
    streamingPlatforms: json["streaming_platforms"],
    crewRoles: json["crew_roles"],
    skillsNeeded: json["skills_needed"],
    equipmentsNeeded: json["equipments_needed"],
    isDraft: json["is_draft"],
    isCompleted: json["is_completed"],
    isCancelled: json["is_cancelled"],
    isActive: json["is_active"],
    bookingStatus: json["booking_status"],
    creativeUserId: json["creative_user_id"],
    paymentStatus: json["payment_status"],
    paymentMethod: json["payment_method"],
    confirmationNumber: json["confirmation_number"],
    transactionId: json["transaction_id"],
    paidAmount: json["paid_amount"],
    paidAt: DateTime.parse(json["paid_at"]),
    payFullInAdvance: json["pay_full_in_advance"],
    clientNotes: json["client_notes"],
    earlyBirdDiscountPct: json["early_bird_discount_pct"],
    baseAmount: json["base_amount"],
    addonsAmount: json["addons_amount"],
    discountAmount: json["discount_amount"],
    totalAmount: json["total_amount"],
    paymentReference: json["payment_reference"],
    createdAt: DateTime.parse(json["created_at"]),
    crewRequirements: json["crew_requirements"],
    clientFullName: json["client_full_name"],
    clientEmail: json["client_email"],
    clientPhone: json["client_phone"],
    shootTypeMaster: ShootTypeMaster.fromJson(json["shoot_type_master"]),
  );

  Map<String, dynamic> toJson() => {
    "duration_hours": durationHours,
    "video_edit_types": List<dynamic>.from(videoEditTypes.map((x) => x)),
    "photo_edit_types": List<dynamic>.from(photoEditTypes.map((x) => x)),
    "stream_project_booking_id": streamProjectBookingId,
    "client_user_id": clientUserId,
    "selected_creative_user_id": selectedCreativeUserId,
    "selected_creatives": selectedCreatives,
    "specialty_id": specialtyId,
    "shoot_type_id": shootTypeId,
    "shoot_type": shootType,
    "deliverable_option": deliverableOption,
    "service_type": serviceType,
    "edit_types": editTypes,
    "project_name": projectName,
    "description": description,
    "reference_link": referenceLink,
    "notes": notes,
    "reference_links": referenceLinks,
    "additional_details": additionalDetails,
    "event_type": eventType,
    "content_type": contentType,
    "event_date": "${eventDate.year.toString().padLeft(4, '0')}-${eventDate.month.toString().padLeft(2, '0')}-${eventDate.day.toString().padLeft(2, '0')}",
    "edits_needed": editsNeeded,
    "start_time": startTime,
    "end_time": endTime,
    "budget": budget,
    "budget_min": budgetMin,
    "budget_max": budgetMax,
    "expected_viewers": expectedViewers,
    "stream_quality": streamQuality,
    "crew_size_needed": crewSizeNeeded,
    "recommended_crew_size": recommendedCrewSize,
    "event_location": eventLocation,
    "event_latitude": eventLatitude,
    "event_longitude": eventLongitude,
    "streaming_platforms": streamingPlatforms,
    "crew_roles": crewRoles,
    "skills_needed": skillsNeeded,
    "equipments_needed": equipmentsNeeded,
    "is_draft": isDraft,
    "is_completed": isCompleted,
    "is_cancelled": isCancelled,
    "is_active": isActive,
    "booking_status": bookingStatus,
    "creative_user_id": creativeUserId,
    "payment_status": paymentStatus,
    "payment_method": paymentMethod,
    "confirmation_number": confirmationNumber,
    "transaction_id": transactionId,
    "paid_amount": paidAmount,
    "paid_at": paidAt.toIso8601String(),
    "pay_full_in_advance": payFullInAdvance,
    "client_notes": clientNotes,
    "early_bird_discount_pct": earlyBirdDiscountPct,
    "base_amount": baseAmount,
    "addons_amount": addonsAmount,
    "discount_amount": discountAmount,
    "total_amount": totalAmount,
    "payment_reference": paymentReference,
    "created_at": createdAt.toIso8601String(),
    "crew_requirements": crewRequirements,
    "client_full_name": clientFullName,
    "client_email": clientEmail,
    "client_phone": clientPhone,
    "shoot_type_master": shootTypeMaster.toJson(),
  };
}
