class DistrictModel {
  final String id;
  final String name;

  const DistrictModel({required this.id, required this.name});

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
        id: json['id'] as String, name: json['name'] as String);
  }
}

class TehsilModel {
  final String id;
  final String districtId;
  final String name;

  const TehsilModel({
    required this.id,
    required this.districtId,
    required this.name,
  });

  factory TehsilModel.fromJson(Map<String, dynamic> json) {
    return TehsilModel(
      id: json['id'] as String,
      districtId: json['districtId'] ?? "",
      name: json['name'] as String,
    );
  }
}

class ProjectModel {
  final String id;
  final String tehsilId;
  final String name;
  final String? description;

  const ProjectModel({
    required this.id,
    required this.tehsilId,
    required this.name,
    this.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      tehsilId: json['tehsilId'] ?? "",
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class TicketModel {
  final String id;
  final String ticketNumber;
  final String citizenId;
  final String districtId;
  final String tehsilId;
  final String projectId;
  final String remarks;
  final String status;
  final String priority;
  final String? assignedAgentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DistrictModel? district;
  final TehsilModel? tehsil;
  final ProjectModel? project;
  final List<TicketCommentModel> comments;
  final List<AttachmentModel> attachments;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.citizenId,
    required this.districtId,
    required this.tehsilId,
    required this.projectId,
    required this.remarks,
    required this.status,
    required this.priority,
    this.assignedAgentId,
    required this.createdAt,
    required this.updatedAt,
    this.district,
    this.tehsil,
    this.project,
    this.comments = const [],
    this.attachments = const [],
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as String,
      ticketNumber: json['ticketNumber'] as String,
      citizenId: json['citizenId'] as String,
      districtId: json['districtId'] as String,
      tehsilId: json['tehsilId'] as String,
      projectId: json['projectId'] as String,
      remarks: json['remarks'] as String,
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignedAgentId: json['assignedAgentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      district: json['district'] != null
          ? DistrictModel.fromJson(json['district'] as Map<String, dynamic>)
          : null,
      tehsil: json['tehsil'] != null
          ? TehsilModel.fromJson(json['tehsil'] as Map<String, dynamic>)
          : null,
      project: json['project'] != null
          ? ProjectModel.fromJson(json['project'] as Map<String, dynamic>)
          : null,
      comments: (json['comments'] as List<dynamic>?)
              ?.map(
                  (e) => TicketCommentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => AttachmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class TicketCommentModel {
  final String id;
  final String ticketId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final String? userName;
  final String? userRole;

  const TicketCommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.userName,
    this.userRole,
  });

  factory TicketCommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return TicketCommentModel(
      id: json['id'] as String,
      ticketId: json['ticketId'] as String,
      userId: json['userId'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: user?['fullName'] as String?,
      userRole: user?['role'] as String?,
    );
  }
}

class AttachmentModel {
  final String id;
  final String fileName;
  final String fileUrl;
  final int fileSize;

  const AttachmentModel({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileUrl: json['fileUrl'] as String,
      fileSize: json['fileSize'] as int,
    );
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? ticketId;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.ticketId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      ticketId: json['ticketId'] as String?,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class TicketAnalytics {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byPriority;

  const TicketAnalytics({
    required this.total,
    required this.byStatus,
    required this.byPriority,
  });

  factory TicketAnalytics.fromJson(Map<String, dynamic> json) {
    final byStatusList = json['byStatus'] as List<dynamic>;
    final byPriorityList = json['byPriority'] as List<dynamic>;
    return TicketAnalytics(
      total: json['total'] as int,
      byStatus: {
        for (final item in byStatusList)
          item['status'] as String: item['_count']['id'] as int,
      },
      byPriority: {
        for (final item in byPriorityList)
          item['priority'] as String: item['_count']['id'] as int,
      },
    );
  }
}
