// Translation of pcgen.system.ProgressContainer

abstract interface class ProgressContainer {
  int getMaximum();
  int getProgress();
  String? getMessage();

  void setValues(int progress, int maximum);
  void setValuesWithMessage(String message, int progress, int maximum);
  void setProgress(int progress);
  void setProgressWithMessage(String message, int progress);
  void setMaximum(int maximum);
  void fireProgressChangedEvent();
}
