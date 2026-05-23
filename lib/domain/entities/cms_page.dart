import 'package:freezed_annotation/freezed_annotation.dart';

part 'cms_page.freezed.dart';

@freezed
class CmsPage with _$CmsPage {
  const factory CmsPage({
    required String id,
    required String slug,
    required String title,
    required String content,
    required DateTime updatedAt,
  }) = _CmsPage;
}
