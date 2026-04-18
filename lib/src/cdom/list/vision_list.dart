import '../base/cdom_list_object.dart';
import '../../core/vision.dart';

// A CDOMListObject for Vision objects.
class VisionList extends CDOMListObject<Vision> {
  @override
  Type get listClass => Vision;

  @override
  bool isType(String type) => false;
}
