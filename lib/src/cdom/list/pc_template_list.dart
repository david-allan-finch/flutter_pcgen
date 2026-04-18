import '../base/cdom_list_object.dart';
import '../../core/pc_template.dart';

// A CDOMListObject for PCTemplate objects.
class PCTemplateList extends CDOMListObject<PCTemplate> {
  @override
  Type get listClass => PCTemplate;

  @override
  bool isType(String type) => false;
}
