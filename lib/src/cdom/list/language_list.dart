import '../base/cdom_list_object.dart';
import '../../core/language.dart';

// A CDOMListObject for Language objects.
class LanguageList extends CDOMListObject<Language> {
  @override
  Type get listClass => Language;

  @override
  bool isType(String type) => false;
}
