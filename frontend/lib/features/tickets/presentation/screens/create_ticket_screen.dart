import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/models/ticket_model.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  int _step = 0;
  List<DistrictModel> _districts = [];
  List<TehsilModel> _tehsils = [];
  List<ProjectModel> _projects = [];
  DistrictModel? _selectedDistrict;
  TehsilModel? _selectedTehsil;
  ProjectModel? _selectedProject;
  final _remarksController = TextEditingController();
  List<PlatformFile> _attachments = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDistricts();
  }

  Future<void> _loadDistricts() async {
    try {
      final districts = await ref.read(ticketRepositoryProvider).getDistricts();
      setState(() => _districts = districts);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadTehsils(String districtId) async {
    try {
      final tehsils = await ref.read(ticketRepositoryProvider).getTehsils(districtId);
      setState(() {
        _tehsils = tehsils;
        _selectedTehsil = null;
        _selectedProject = null;
        _projects = [];
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadProjects(String tehsilId) async {
    try {
      final projects = await ref.read(ticketRepositoryProvider).getProjects(tehsilId);
      setState(() {
        _projects = projects;
        _selectedProject = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      allowMultiple: true,
    );
    if (result != null) {
      for (final file in result.files) {
        if (file.size > 2 * 1024 * 1024) {
          setState(() => _error = '${file.name} exceeds 2 MB limit');
          return;
        }
      }
      setState(() => _attachments = result.files);
    }
  }

  Future<void> _submit() async {
    if (_selectedDistrict == null ||
        _selectedTehsil == null ||
        _selectedProject == null ||
        _remarksController.text.length < 10) {
      setState(() => _error = 'Please complete all steps');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final files = <MultipartFile>[];
      for (final file in _attachments) {
        if (file.path != null) {
          files.add(await MultipartFile.fromFile(file.path!, filename: file.name));
        }
      }

      final ticket = await ref.read(ticketRepositoryProvider).createTicket(
            districtId: _selectedDistrict!.id,
            tehsilId: _selectedTehsil!.id,
            projectId: _selectedProject!.id,
            remarks: _remarksController.text,
            attachments: files,
          );

      ref.invalidate(ticketsProvider(null));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket ${ticket.ticketNumber} created!')),
        );
        context.go('/tickets/${ticket.id}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ticket')),
      body: ResponsiveLayout(
        child: Stepper(
          currentStep: _step,
          onStepContinue: () {
            if (_step < 5) {
              setState(() => _step++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              context.pop();
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : details.onStepContinue,
                    child: Text(_step == 5 ? 'Submit' : 'Continue'),
                  ),
                  const SizedBox(width: 8),
                  if (_step > 0)
                    TextButton(onPressed: details.onStepCancel, child: const Text('Back')),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Select District'),
              isActive: _step >= 0,
              content: DropdownButtonFormField<DistrictModel>(
                decoration: const InputDecoration(labelText: 'District'),
                value: _selectedDistrict,
                items: _districts
                    .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                    .toList(),
                onChanged: (d) {
                  setState(() => _selectedDistrict = d);
                  if (d != null) _loadTehsils(d.id);
                },
              ),
            ),
            Step(
              title: const Text('Select Tehsil'),
              isActive: _step >= 1,
              content: DropdownButtonFormField<TehsilModel>(
                decoration: const InputDecoration(labelText: 'Tehsil'),
                value: _selectedTehsil,
                items: _tehsils
                    .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                    .toList(),
                onChanged: (t) {
                  setState(() => _selectedTehsil = t);
                  if (t != null) _loadProjects(t.id);
                },
              ),
            ),
            Step(
              title: const Text('Select Project'),
              isActive: _step >= 2,
              content: DropdownButtonFormField<ProjectModel>(
                decoration: const InputDecoration(labelText: 'Project'),
                value: _selectedProject,
                items: _projects
                    .map((p) => DropdownMenuItem(value: p, child: Text(p.name)))
                    .toList(),
                onChanged: (p) => setState(() => _selectedProject = p),
              ),
            ),
            Step(
              title: const Text('Enter Remarks'),
              isActive: _step >= 3,
              content: TextField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Describe your complaint',
                  hintText: 'Minimum 10 characters',
                ),
                maxLines: 5,
                maxLength: 2000,
              ),
            ),
            Step(
              title: const Text('Upload Attachments'),
              isActive: _step >= 4,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Allowed: jpg, jpeg, png, pdf (max 2 MB each)'),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Choose Files'),
                  ),
                  ..._attachments.map((f) => ListTile(
                        dense: true,
                        title: Text(f.name),
                        subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
                      )),
                ],
              ),
            ),
            Step(
              title: const Text('Review & Submit'),
              isActive: _step >= 5,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('District: ${_selectedDistrict?.name ?? "-"}'),
                  Text('Tehsil: ${_selectedTehsil?.name ?? "-"}'),
                  Text('Project: ${_selectedProject?.name ?? "-"}'),
                  Text('Remarks: ${_remarksController.text}'),
                  Text('Attachments: ${_attachments.length} file(s)'),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_error!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (_loading) const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}
