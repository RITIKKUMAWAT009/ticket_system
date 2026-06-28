const { TicketService } = require('../../src/modules/tickets/ticket.service');

describe('TicketService', () => {
  let service;
  let mockRepository;
  let mockNotificationService;

  beforeEach(() => {
    mockRepository = {
      create: jest.fn(),
      findById: jest.fn(),
      findMany: jest.fn(),
      updateStatus: jest.fn(),
      assign: jest.fn(),
      addComment: jest.fn(),
      addAttachments: jest.fn(),
      getAnalytics: jest.fn(),
    };
    mockNotificationService = {
      notifyTicketCreated: jest.fn(),
      notifyTicketAssigned: jest.fn(),
      notifyStatusChanged: jest.fn(),
      notifyCommentAdded: jest.fn(),
      notifyTicketClosed: jest.fn(),
      notifyTicketReopened: jest.fn(),
    };
    service = new TicketService(mockRepository, mockNotificationService);
  });

  test('citizen can only see own tickets', async () => {
    const citizen = { id: 'citizen-1', role: 'CITIZEN', fullName: 'Test' };
    mockRepository.findMany.mockResolvedValue({ tickets: [], total: 0 });

    await service.list(citizen);

    expect(mockRepository.findMany).toHaveBeenCalledWith(
      { citizenId: 'citizen-1' },
      expect.any(Object)
    );
  });

  test('agent can only see assigned tickets', async () => {
    const agent = { id: 'agent-1', role: 'SUPPORT_AGENT', fullName: 'Agent' };
    mockRepository.findMany.mockResolvedValue({ tickets: [], total: 0 });

    await service.list(agent);

    expect(mockRepository.findMany).toHaveBeenCalledWith(
      { assignedAgentId: 'agent-1' },
      expect.any(Object)
    );
  });

  test('admin sees all tickets', async () => {
    const admin = { id: 'admin-1', role: 'ADMIN', fullName: 'Admin' };
    mockRepository.findMany.mockResolvedValue({ tickets: [], total: 0 });

    await service.list(admin);

    expect(mockRepository.findMany).toHaveBeenCalledWith({}, expect.any(Object));
  });

  test('citizen cannot update ticket status', async () => {
    const citizen = { id: 'c-1', role: 'CITIZEN', fullName: 'Citizen' };
    mockRepository.findById.mockResolvedValue({
      id: 't-1',
      citizenId: 'c-1',
      assignedAgentId: null,
    });

    await expect(
      service.updateStatus('t-1', citizen, { status: 'CLOSED' })
    ).rejects.toMatchObject({ status: 403 });
  });

  test('creates ticket and sends notification', async () => {
    const ticket = {
      id: 't-1',
      ticketNumber: 'TKT-20260001',
      citizenId: 'c-1',
    };
    mockRepository.create.mockResolvedValue(ticket);
    mockRepository.findById.mockResolvedValue(ticket);

    const result = await service.create('c-1', {
      districtId: 'd-1',
      tehsilId: 't-1',
      projectId: 'p-1',
      remarks: 'Test complaint with enough length',
    });

    expect(result).toEqual(ticket);
    expect(mockNotificationService.notifyTicketCreated).toHaveBeenCalledWith(ticket, 'c-1');
  });
});
