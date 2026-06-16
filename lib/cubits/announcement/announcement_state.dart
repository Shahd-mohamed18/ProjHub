// lib/cubits/announcement/announcement_state.dart

import 'package:equatable/equatable.dart';
import 'package:onboard/models/AnnouncementModels/announcement_model.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();

  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {
  const AnnouncementInitial();
}

class AnnouncementLoading extends AnnouncementState {
  const AnnouncementLoading();
}

class AnnouncementLoaded extends AnnouncementState {
  final List<AnnouncementModel> announcements;

  const AnnouncementLoaded({required this.announcements});

  @override
  List<Object?> get props => [announcements];

  AnnouncementLoaded copyWith({List<AnnouncementModel>? announcements}) {
    return AnnouncementLoaded(
      announcements: announcements ?? this.announcements,
    );
  }
}

class AnnouncementError extends AnnouncementState {
  final String message;

  const AnnouncementError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnnouncementPosting extends AnnouncementState {
  const AnnouncementPosting();
}

class AnnouncementPosted extends AnnouncementState {
  const AnnouncementPosted();
}

class AnnouncementDeleting extends AnnouncementState {
  const AnnouncementDeleting();
}

class AnnouncementDeleted extends AnnouncementState {
  const AnnouncementDeleted();
}