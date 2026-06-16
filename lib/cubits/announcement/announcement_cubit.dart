// lib/cubits/announcement/announcement_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboard/cubits/announcement/announcement_state.dart';
import 'package:onboard/models/AnnouncementModels/announcement_model.dart';
import 'package:onboard/services/announcement_service.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  AnnouncementCubit() : super(const AnnouncementInitial());

  final AnnouncementService _service = AnnouncementService();

  int? _currentTeamId;

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> loadAnnouncements({
    required int teamId,
    String? userId,
  }) async {
    if (isClosed) return; // ✅ منع الإصدار بعد الإغلاق
    _currentTeamId = teamId;
    emit(const AnnouncementLoading());
    try {
      final list = await _service.getAnnouncements(
        teamId: teamId,
        userId: userId,
      );
      if (!isClosed) {
        emit(AnnouncementLoaded(announcements: list));
      }
    } catch (e) {
      if (!isClosed) {
        emit(AnnouncementError('Failed to load announcements: $e'));
      }
    }
  }

  // ── Create ──────────────────────────────────────────────────────────────────

  Future<bool> createAnnouncement({
    required String message,
    String? meetingLink,
    required int teamId,
    required String supervisorId,
    required String supervisorName,
  }) async {
    if (isClosed) return false;
    final previousState = state;
    emit(const AnnouncementPosting());
    try {
      final ok = await _service.createAnnouncement(
        message: message,
        meetingLink: meetingLink,
        teamId: teamId,
        supervisorId: supervisorId,
        supervisorName: supervisorName,
      );

      if (ok) {
        if (!isClosed) {
          emit(const AnnouncementPosted());
          // ✅ إعادة تحميل الإعلانات مع userId الخاص بالمشرف
          await loadAnnouncements(
            teamId: teamId,
            userId: supervisorId, // ✅ تمرير userId صحيح
          );
        }
        return true;
      } else {
        if (!isClosed) {
          emit(const AnnouncementError('Failed to create announcement'));
          if (previousState is AnnouncementLoaded) emit(previousState);
        }
        return false;
      }
    } catch (e) {
      if (!isClosed) {
        emit(AnnouncementError('Error: $e'));
        if (previousState is AnnouncementLoaded) emit(previousState);
      }
      return false;
    }
  }

  // ── Delete ──────────────────────────────────────────────────────────────────

  /// Deletes all announcements for the current team (supervisor only).
  Future<bool> deleteAnnouncements({
    required int teamId,
    required String supervisorId,
  }) async {
    if (isClosed) return false;
    final previousState = state;
    emit(const AnnouncementDeleting());
    try {
      final ok = await _service.deleteAnnouncements(
        teamId: teamId,
        supervisorId: supervisorId,
      );

      if (ok) {
        if (!isClosed) {
          emit(const AnnouncementDeleted());
          emit(const AnnouncementLoaded(announcements: []));
        }
        return true;
      } else {
        if (!isClosed) {
          emit(const AnnouncementError('Failed to delete announcements'));
          if (previousState is AnnouncementLoaded) emit(previousState);
        }
        return false;
      }
    } catch (e) {
      if (!isClosed) {
        emit(AnnouncementError('Error: $e'));
        if (previousState is AnnouncementLoaded) emit(previousState);
      }
      return false;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  List<AnnouncementModel> get currentAnnouncements {
    final s = state;
    return s is AnnouncementLoaded ? s.announcements : [];
  }

  int? get currentTeamId => _currentTeamId;
}