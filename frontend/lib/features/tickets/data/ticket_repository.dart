import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../tickets/domain/models/ticket_model.dart';

class TicketRepository {
  TicketRepository(this._client);

  final ApiClient _client;

  Future<List<DistrictModel>> getDistricts() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.districts);
    final list = response['data'] as List<dynamic>;
    return list.map((e) => DistrictModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<TehsilModel>> getTehsils(String districtId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.districtTehsils(districtId),
    );
    final list = response['data'] as List<dynamic>;
    return list.map((e) => TehsilModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProjectModel>> getProjects(String tehsilId) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.tehsilProjects(tehsilId),
    );
    final list = response['data'] as List<dynamic>;
    return list.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TicketModel> createTicket({
    required String districtId,
    required String tehsilId,
    required String projectId,
    required String remarks,
    List<MultipartFile> attachments = const [],
  }) async {
    final response = await _client.uploadMultipart<Map<String, dynamic>>(
      ApiConstants.tickets,
      {
        'districtId': districtId,
        'tehsilId': tehsilId,
        'projectId': projectId,
        'remarks': remarks,
      },
      attachments,
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<TicketModel>> getTickets({String? status}) async {
    final response = await _client.get<Map<String, dynamic>>(
      ApiConstants.tickets,
      queryParameters: status != null ? {'status': status} : null,
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = data['tickets'] as List<dynamic>;
    return list.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TicketModel> getTicket(String id) async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.ticketById(id));
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TicketModel> updateStatus(String id, String status, {String? priority}) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiConstants.ticketStatus(id),
      data: {
        'status': status,
        if (priority != null) 'priority': priority,
      },
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TicketModel> assignTicket(String id, String agentId) async {
    final response = await _client.patch<Map<String, dynamic>>(
      ApiConstants.ticketAssign(id),
      data: {'agentId': agentId},
    );
    return TicketModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TicketCommentModel> addComment(String ticketId, String message) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.ticketComments(ticketId),
      data: {'message': message},
    );
    return TicketCommentModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TicketAnalytics> getAnalytics() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.ticketAnalytics);
    return TicketAnalytics.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DistrictModel> createDistrict(String name) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.districts,
      data: {'name': name},
    );
    return DistrictModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<TehsilModel> createTehsil(String districtId, String name) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.tehsils,
      data: {'districtId': districtId, 'name': name},
    );
    return TehsilModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ProjectModel> createProject(String tehsilId, String name, String? description) async {
    final response = await _client.post<Map<String, dynamic>>(
      ApiConstants.projects,
      data: {'tehsilId': tehsilId, 'name': name, 'description': description},
    );
    return ProjectModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}

class NotificationRepository {
  NotificationRepository(this._client);

  final ApiClient _client;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _client.get<Map<String, dynamic>>(ApiConstants.notifications);
    final data = response['data'] as Map<String, dynamic>;
    final list = data['notifications'] as List<dynamic>;
    return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _client.patch(ApiConstants.notificationRead(id));
  }

  Future<void> markAllAsRead() async {
    await _client.patch(ApiConstants.notificationsReadAll);
  }
}
