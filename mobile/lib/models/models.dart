class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleLabel,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String roleLabel;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      roleLabel: json['role_label'] as String? ?? json['role'] as String,
    );
  }
}

class ChildModel {
  ChildModel({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.level,
    this.avatar,
    this.completedAttemptsCount = 0,
    this.averageStars = 0,
    this.parent,
    this.completionRate,
    this.trainedWordsCount,
    this.totalAttemptsCount,
    this.overallPerformanceScore,
  });

  final int id;
  final String name;
  final int age;
  final String gender;
  final int level;
  final String? avatar;
  final int completedAttemptsCount;
  final double averageStars;
  final ParentSummary? parent;
  final double? completionRate;
  final int? trainedWordsCount;
  final int? totalAttemptsCount;
  final double? overallPerformanceScore;

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      level: json['level'] as int,
      avatar: json['avatar'] as String?,
      completedAttemptsCount: json['completed_attempts_count'] as int? ?? 0,
      averageStars: (json['average_stars'] as num?)?.toDouble() ?? 0,
      parent: json['parent'] != null
          ? ParentSummary.fromJson(json['parent'] as Map<String, dynamic>)
          : null,
      completionRate: (json['completion_rate'] as num?)?.toDouble(),
      trainedWordsCount: json['trained_words_count'] as int?,
      totalAttemptsCount: json['total_attempts_count'] as int?,
      overallPerformanceScore:
          (json['overall_performance_score'] as num?)?.toDouble(),
    );
  }
}

class ParentSummary {
  ParentSummary({required this.id, required this.name, this.email});

  final int id;
  final String name;
  final String? email;

  factory ParentSummary.fromJson(Map<String, dynamic> json) {
    return ParentSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
    );
  }
}

class WorldModel {
  WorldModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.iconUrl,
    this.itemsCount,
  });

  final int id;
  final String name;
  final int sortOrder;
  final String? iconUrl;
  final int? itemsCount;

  factory WorldModel.fromJson(Map<String, dynamic> json) {
    return WorldModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int? ?? 0,
      iconUrl: json['icon_url'] as String?,
      itemsCount: json['items_count'] as int?,
    );
  }
}

class ActivityModel {
  ActivityModel({
    required this.id,
    required this.type,
    required this.typeLabel,
  });

  final int id;
  final String type;
  final String typeLabel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as int,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String? ?? json['type'] as String,
    );
  }
}

class ItemModel {
  ItemModel({
    required this.id,
    required this.wordName,
    required this.minLevel,
    this.imageUrl,
    this.audioUrl,
    this.activities = const [],
  });

  final int id;
  final String wordName;
  final int minLevel;
  final String? imageUrl;
  final String? audioUrl;
  final List<ActivityModel> activities;

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int,
      wordName: json['word_name'] as String,
      minLevel: json['min_level'] as int? ?? 1,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BootstrapModel {
  BootstrapModel({
    required this.appName,
    required this.authenticated,
    required this.worlds,
    this.user,
    this.children = const [],
  });

  final String appName;
  final bool authenticated;
  final List<WorldModel> worlds;
  final UserModel? user;
  final List<ChildModel> children;

  factory BootstrapModel.fromJson(Map<String, dynamic> json) {
    final app = json['app'] as Map<String, dynamic>? ?? {};

    return BootstrapModel(
      appName: app['name'] as String? ?? 'كلامو',
      authenticated: json['authenticated'] as bool? ?? false,
      worlds: (json['worlds'] as List<dynamic>? ?? [])
          .map((e) => WorldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>? ?? [])
          .map((e) => ChildModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProgressActivityTypeStat {
  ProgressActivityTypeStat({
    required this.type,
    required this.label,
    required this.count,
    required this.stars,
  });

  final String type;
  final String label;
  final int count;
  final int stars;

  factory ProgressActivityTypeStat.fromJson(Map<String, dynamic> json) {
    return ProgressActivityTypeStat(
      type: json['type'] as String? ?? '',
      label: json['label'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
    );
  }
}

class ProgressWorldStat {
  ProgressWorldStat({
    required this.worldId,
    required this.worldName,
    required this.completed,
    required this.stars,
    required this.totalAvailable,
  });

  final int worldId;
  final String worldName;
  final int completed;
  final int stars;
  final int totalAvailable;

  double get completionPercent =>
      totalAvailable == 0 ? 0 : (completed / totalAvailable) * 100;

  factory ProgressWorldStat.fromJson(Map<String, dynamic> json) {
    return ProgressWorldStat(
      worldId: json['world_id'] as int? ?? 0,
      worldName: json['world_name'] as String? ?? '',
      completed: json['completed'] as int? ?? 0,
      stars: json['stars'] as int? ?? 0,
      totalAvailable: json['total_available'] as int? ?? 0,
    );
  }
}

class ProgressStarsBucket {
  ProgressStarsBucket({required this.stars, required this.count});

  final int stars;
  final int count;

  factory ProgressStarsBucket.fromJson(Map<String, dynamic> json) {
    return ProgressStarsBucket(
      stars: json['stars'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
    );
  }
}

class ProgressRecentActivity {
  ProgressRecentActivity({
    required this.wordName,
    required this.activityType,
    required this.activityLabel,
    required this.worldName,
    required this.starsEarned,
    this.completedAt,
  });

  final String? wordName;
  final String? activityType;
  final String? activityLabel;
  final String? worldName;
  final int starsEarned;
  final String? completedAt;

  factory ProgressRecentActivity.fromJson(Map<String, dynamic> json) {
    return ProgressRecentActivity(
      wordName: json['word_name'] as String?,
      activityType: json['activity_type'] as String?,
      activityLabel: json['activity_label'] as String?,
      worldName: json['world_name'] as String?,
      starsEarned: json['stars_earned'] as int? ?? 0,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class ProgressDayStat {
  ProgressDayStat({
    required this.label,
    required this.date,
    required this.count,
  });

  final String label;
  final String date;
  final int count;

  factory ProgressDayStat.fromJson(Map<String, dynamic> json) {
    return ProgressDayStat(
      label: json['label'] as String? ?? '',
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class ProgressModel {
  ProgressModel({
    required this.level,
    required this.completedActivitiesCount,
    required this.uniqueActivitiesCount,
    required this.totalAttemptsCount,
    required this.trainedWordsCount,
    required this.availableActivitiesCount,
    required this.completionRate,
    required this.overallPerformanceScore,
    required this.totalStars,
    required this.averageStars,
    required this.maxStarsPerActivity,
    required this.byActivityType,
    required this.byWorld,
    required this.starsDistribution,
    required this.recentActivities,
    required this.weeklyActivity,
  });

  final int level;
  final int completedActivitiesCount;
  final int uniqueActivitiesCount;
  final int totalAttemptsCount;
  final int trainedWordsCount;
  final int availableActivitiesCount;
  final double completionRate;
  final double overallPerformanceScore;
  final int totalStars;
  final double averageStars;
  final int maxStarsPerActivity;
  final List<ProgressActivityTypeStat> byActivityType;
  final List<ProgressWorldStat> byWorld;
  final List<ProgressStarsBucket> starsDistribution;
  final List<ProgressRecentActivity> recentActivities;
  final List<ProgressDayStat> weeklyActivity;

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      level: json['level'] as int? ?? 1,
      completedActivitiesCount: json['completed_activities_count'] as int? ?? 0,
      uniqueActivitiesCount: json['unique_activities_count'] as int? ?? 0,
      totalAttemptsCount: json['total_attempts_count'] as int? ?? 0,
      trainedWordsCount: json['trained_words_count'] as int? ?? 0,
      availableActivitiesCount: json['available_activities_count'] as int? ?? 0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
      overallPerformanceScore:
          (json['overall_performance_score'] as num?)?.toDouble() ?? 0,
      totalStars: json['total_stars'] as int? ?? 0,
      averageStars: (json['average_stars'] as num?)?.toDouble() ?? 0,
      maxStarsPerActivity: json['max_stars_per_activity'] as int? ?? 5,
      byActivityType: (json['by_activity_type'] as List<dynamic>? ?? [])
          .map((e) => ProgressActivityTypeStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      byWorld: (json['by_world'] as List<dynamic>? ?? [])
          .map((e) => ProgressWorldStat.fromJson(e as Map<String, dynamic>))
          .toList(),
      starsDistribution: (json['stars_distribution'] as List<dynamic>? ?? [])
          .map((e) => ProgressStarsBucket.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentActivities: (json['recent_activities'] as List<dynamic>? ?? [])
          .map((e) => ProgressRecentActivity.fromJson(e as Map<String, dynamic>))
          .toList(),
      weeklyActivity: (json['weekly_activity'] as List<dynamic>? ?? [])
          .map((e) => ProgressDayStat.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ActivitySessionModel {
  ActivitySessionModel({
    required this.activity,
    required this.item,
    this.instruction,
    this.questionText,
    this.questionAudioUrl,
    this.choices = const [],
  });

  final ActivityModel activity;
  final ItemModel item;
  final String? instruction;
  final String? questionText;
  final String? questionAudioUrl;
  final List<ItemModel> choices;

  factory ActivitySessionModel.fromJson(Map<String, dynamic> json) {
    final question = json['question'] as Map<String, dynamic>?;

    return ActivitySessionModel(
      activity: ActivityModel.fromJson(json['activity'] as Map<String, dynamic>),
      item: ItemModel.fromJson(json['item'] as Map<String, dynamic>),
      instruction: json['instruction'] as String?,
      questionText: question?['text'] as String?,
      questionAudioUrl: question?['audio_url'] as String?,
      choices: (json['choices'] as List<dynamic>? ?? [])
          .map((e) => ItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AttemptResultModel {
  AttemptResultModel({
    required this.id,
    required this.starsEarned,
    required this.isCompleted,
    this.aiAnalysisStatus,
    this.analysisText,
    this.isCorrect,
    this.matchPercentage,
    this.errorPercentage,
    this.scoreSummary,
    this.missingLetters = const [],
    this.heardTranscription,
    this.analysisSource,
  });

  final int id;
  final int starsEarned;
  final bool isCompleted;
  final String? aiAnalysisStatus;
  final String? analysisText;
  final bool? isCorrect;
  final int? matchPercentage;
  final int? errorPercentage;
  final String? scoreSummary;
  final List<String> missingLetters;
  final String? heardTranscription;
  final String? analysisSource;

  bool get isAnalysisPending =>
      aiAnalysisStatus == 'pending' || aiAnalysisStatus == 'processing';

  bool get isAnalysisFailed => aiAnalysisStatus == 'failed';

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    return AttemptResultModel(
      id: json['id'] as int,
      starsEarned: json['stars_earned'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? true,
      aiAnalysisStatus: json['ai_analysis_status'] as String?,
      analysisText: json['analysis_text'] as String?,
      isCorrect: json['is_correct'] as bool?,
      matchPercentage: json['match_percentage'] as int?,
      errorPercentage: json['error_percentage'] as int?,
      scoreSummary: json['score_summary'] as String?,
      missingLetters: (json['missing_letters'] as List<dynamic>? ?? [])
          .map((letter) => letter.toString())
          .toList(),
      heardTranscription: json['heard_transcription'] as String?,
      analysisSource: json['analysis_source'] as String?,
    );
  }
}

class DashboardStatsModel {
  DashboardStatsModel({
    required this.childrenCount,
    required this.completedActivitiesCount,
    required this.averageStars,
    required this.averagePerformancePercent,
    required this.maxStars,
  });

  final int childrenCount;
  final int completedActivitiesCount;
  final double averageStars;
  final double averagePerformancePercent;
  final int maxStars;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      childrenCount: json['children_count'] as int? ?? 0,
      completedActivitiesCount: json['completed_activities_count'] as int? ?? 0,
      averageStars: (json['average_stars'] as num?)?.toDouble() ?? 0,
      averagePerformancePercent:
          (json['average_performance_percent'] as num?)?.toDouble() ?? 0,
      maxStars: json['max_stars'] as int? ?? 5,
    );
  }
}

class RecentSessionModel {
  RecentSessionModel({
    required this.id,
    required this.childId,
    this.childName,
    this.wordName,
    this.activityLabel,
    this.worldName,
    required this.starsEarned,
    this.completedAt,
  });

  final int id;
  final int childId;
  final String? childName;
  final String? wordName;
  final String? activityLabel;
  final String? worldName;
  final int starsEarned;
  final String? completedAt;

  factory RecentSessionModel.fromJson(Map<String, dynamic> json) {
    return RecentSessionModel(
      id: json['id'] as int,
      childId: json['child_id'] as int,
      childName: json['child_name'] as String?,
      wordName: json['word_name'] as String?,
      activityLabel: json['activity_label'] as String?,
      worldName: json['world_name'] as String?,
      starsEarned: json['stars_earned'] as int? ?? 0,
      completedAt: json['completed_at'] as String?,
    );
  }
}

class ChildReportModel {
  ChildReportModel({required this.child, required this.metrics});

  final ChildModel child;
  final ChildReportMetrics metrics;

  factory ChildReportModel.fromJson(Map<String, dynamic> json) {
    return ChildReportModel(
      child: ChildModel.fromJson(json['child'] as Map<String, dynamic>),
      metrics: ChildReportMetrics.fromJson(json),
    );
  }
}

class ChildReportMetrics {
  ChildReportMetrics({
    required this.completionRate,
    required this.trainedWordsCount,
    required this.totalAttemptsCount,
    required this.overallPerformanceScore,
    required this.averageStars,
    required this.completedActivitiesCount,
  });

  final double completionRate;
  final int trainedWordsCount;
  final int totalAttemptsCount;
  final double overallPerformanceScore;
  final double averageStars;
  final int completedActivitiesCount;

  factory ChildReportMetrics.fromJson(Map<String, dynamic> json) {
    return ChildReportMetrics(
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0,
      trainedWordsCount: json['trained_words_count'] as int? ?? 0,
      totalAttemptsCount: json['total_attempts_count'] as int? ?? 0,
      overallPerformanceScore:
          (json['overall_performance_score'] as num?)?.toDouble() ?? 0,
      averageStars: (json['average_stars'] as num?)?.toDouble() ?? 0,
      completedActivitiesCount: json['completed_activities_count'] as int? ?? 0,
    );
  }
}

class AttemptListItemModel {
  AttemptListItemModel({
    required this.id,
    required this.childId,
    this.childName,
    this.wordName,
    this.activityTypeLabel,
    required this.starsEarned,
    required this.maxStars,
    required this.isCompleted,
    this.audioRecordingUrl,
    this.aiAnalysisStatus,
    this.aiAnalysisStatusLabel,
    this.analysisText,
    this.isCorrect,
    this.matchPercentage,
    this.heardTranscription,
    this.createdAt,
  });

  final int id;
  final int childId;
  final String? childName;
  final String? wordName;
  final String? activityTypeLabel;
  final int starsEarned;
  final int maxStars;
  final bool isCompleted;
  final String? audioRecordingUrl;
  final String? aiAnalysisStatus;
  final String? aiAnalysisStatusLabel;
  final String? analysisText;
  final bool? isCorrect;
  final int? matchPercentage;
  final String? heardTranscription;
  final String? createdAt;

  bool get hasAudio => audioRecordingUrl != null && audioRecordingUrl!.isNotEmpty;

  factory AttemptListItemModel.fromJson(Map<String, dynamic> json) {
    return AttemptListItemModel(
      id: json['id'] as int,
      childId: json['child_id'] as int,
      childName: json['child_name'] as String?,
      wordName: json['word_name'] as String?,
      activityTypeLabel: json['activity_type_label'] as String?,
      starsEarned: json['stars_earned'] as int? ?? 0,
      maxStars: json['max_stars'] as int? ?? 5,
      isCompleted: json['is_completed'] as bool? ?? false,
      audioRecordingUrl: json['audio_recording_url'] as String?,
      aiAnalysisStatus: json['ai_analysis_status'] as String?,
      aiAnalysisStatusLabel: json['ai_analysis_status_label'] as String?,
      analysisText: json['analysis_text'] as String?,
      isCorrect: json['is_correct'] as bool?,
      matchPercentage: json['match_percentage'] as int?,
      heardTranscription: json['heard_transcription'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class ContentStatsModel {
  ContentStatsModel({
    required this.worldsCount,
    required this.itemsCount,
    required this.activitiesCount,
  });

  final int worldsCount;
  final int itemsCount;
  final int activitiesCount;

  factory ContentStatsModel.fromJson(Map<String, dynamic> json) {
    return ContentStatsModel(
      worldsCount: json['worlds_count'] as int? ?? 0,
      itemsCount: json['items_count'] as int? ?? 0,
      activitiesCount: json['activities_count'] as int? ?? 0,
    );
  }
}

class AdminUserModel {
  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.roleLabel,
    this.childrenCount = 0,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String roleLabel;
  final int childrenCount;

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      roleLabel: json['role_label'] as String? ?? json['role'] as String,
      childrenCount: json['children_count'] as int? ?? 0,
    );
  }
}

class AdminItemModel {
  AdminItemModel({
    required this.id,
    required this.worldId,
    required this.wordName,
    required this.minLevel,
    this.worldName,
    this.imageUrl,
    this.audioUrl,
    this.activities = const [],
  });

  final int id;
  final int worldId;
  final String wordName;
  final int minLevel;
  final String? worldName;
  final String? imageUrl;
  final String? audioUrl;
  final List<ActivityModel> activities;

  factory AdminItemModel.fromJson(Map<String, dynamic> json) {
    return AdminItemModel(
      id: json['id'] as int,
      worldId: json['world_id'] as int? ?? 0,
      wordName: json['word_name'] as String,
      minLevel: json['min_level'] as int? ?? 1,
      worldName: json['world_name'] as String?,
      imageUrl: json['image_url'] as String?,
      audioUrl: json['audio_url'] as String?,
      activities: (json['activities'] as List<dynamic>? ?? [])
          .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AdminActivityModel {
  AdminActivityModel({
    required this.id,
    required this.itemId,
    required this.type,
    required this.typeLabel,
    this.wordName,
    this.worldName,
  });

  final int id;
  final int itemId;
  final String type;
  final String typeLabel;
  final String? wordName;
  final String? worldName;

  factory AdminActivityModel.fromJson(Map<String, dynamic> json) {
    return AdminActivityModel(
      id: json['id'] as int,
      itemId: json['item_id'] as int? ?? 0,
      type: json['type'] as String,
      typeLabel: json['type_label'] as String? ?? json['type'] as String,
      wordName: json['word_name'] as String?,
      worldName: json['world_name'] as String?,
    );
  }
}
