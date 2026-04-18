import '../base/cdom_list_object.dart';
import '../../core/domain.dart';

// A CDOMListObject for Domain objects.
class DomainList extends CDOMListObject<Domain> {
  @override
  Type get listClass => Domain;

  @override
  bool isType(String type) => false;
}
