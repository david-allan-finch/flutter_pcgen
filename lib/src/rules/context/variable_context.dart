import '../../base/util/format_manager.dart';
import '../../formula/base/formula_function.dart';
import '../../formula/base/implemented_scope.dart';
import '../../formula/base/scope_instance.dart';
import '../../formula/base/variable_id.dart';
import '../../formula/base/variable_library.dart';
import '../../formula/base/writeable_function_library.dart';
import '../../formula/base/writeable_variable_store.dart';
import '../../formula/inst/nep_formula.dart';
import '../../formula/inst/simple_function_library.dart';
import '../../formula/inst/variable_manager.dart';
import '../../formula/solver/solver_manager.dart';

// TODO: The following Java types are not yet translated to Dart.
// They are represented as dynamic until translations are available.
//
//   FormulaSetupFactory   → pcgen.base.solver.FormulaSetupFactory
//   ManagerFactory        → pcgen.base.formula.base.ManagerFactory
//   SupplierValueStore    → pcgen.base.solver.SupplierValueStore
//   SimpleSolverFactory   → pcgen.base.solver.SimpleSolverFactory
//   SolverFactory         → pcgen.base.solver.SolverFactory
//   ScopeManagerInst      → pcgen.base.formula.inst.ScopeManagerInst
//   DynamicSolverManager  → pcgen.base.solver.DynamicSolverManager
//   FormulaModifier<T>    → pcgen.base.calculation.FormulaModifier
//   IgnoreVariables       → pcgen.base.calculation.IgnoreVariables
//   FormulaManager        → pcgen.base.formula.base.FormulaManager
//   LegalScope            → pcgen.base.formula.base.LegalScope
//   PCGenScope            → pcgen.cdom.formula.scope.PCGenScope
//   PluginFunctionLibrary → pcgen.cdom.formula.PluginFunctionLibrary
//   FormulaUtilities      → pcgen.base.formula.inst.FormulaUtilities
//   LegalScopeUtilities   → pcgen.cdom.formula.scope.LegalScopeUtilities
//   FormulaFactory        → pcgen.cdom.base.FormulaFactory
//   ManagerKey            → pcgen.cdom.formula.ManagerKey
//   ReferenceDependency   → pcgen.cdom.helper.ReferenceDependency
//   TokenLibrary          → pcgen.rules.persistence.TokenLibrary
//   ComplexResult<T>      → pcgen.base.util.ComplexResult
//   VariableChannel<?>    → pcgen.cdom.formula.VariableChannel
//   VariableChannelFactory/FactoryInst → pcgen.cdom.formula.VariableChannelFactory*
//   VariableWrapper<?>    → pcgen.cdom.formula.VariableWrapper
//   VariableWrapperFactory/FactoryInst → pcgen.cdom.formula.VariableWrapperFactory*

/// A VariableContext is responsible for managing variable items during the load
/// of data and (in some cases) subsequently while the data set associated with
/// the parent LoadContext is operating.
class VariableContext implements VariableLibrary {
  // TODO: Replace dynamic with FormulaSetupFactory once translated.
  final dynamic _formulaSetupFactory;

  // TODO: Replace dynamic with ManagerFactory once translated.
  final dynamic _managerFactory;

  // The WriteableFunctionLibrary for this VariableContext.
  final WriteableFunctionLibrary _myFunctionLibrary = SimpleFunctionLibrary();

  // TODO: Replace dynamic with SupplierValueStore once translated.
  final dynamic _myValueStore;

  // TODO: Replace dynamic with SolverFactory once translated.
  final dynamic _solverFactory;

  // TODO: Replace dynamic with ScopeManagerInst once translated.
  final dynamic _legalScopeManager;

  // The VariableManager for this VariableContext.
  late final VariableManager _variableManager;

  /// The naive FormulaManager for this VariableContext. Lazy — null until first
  /// call to [getFormulaManager].
  // TODO: Replace dynamic with FormulaManager once translated.
  dynamic _loadFormulaManager;

  // TODO: Replace dynamic with VariableChannelFactoryInst once translated.
  final dynamic _variableChannelFactory;

  // TODO: Replace dynamic with VariableWrapperFactoryInst once translated.
  final dynamic _variableWrapperFactory;

  /// Constructs a new VariableContext with the given ManagerFactory.
  ///
  /// [managerFactory] – The ManagerFactory used to generate managers for
  /// formula evaluation by all items loaded while this VariableContext is active.
  VariableContext(dynamic managerFactory)
      : _managerFactory = managerFactory,
        // TODO: Instantiate real FormulaSetupFactory, SupplierValueStore,
        //       SimpleSolverFactory, ScopeManagerInst when translated.
        _formulaSetupFactory = null,
        _myValueStore = null,
        _solverFactory = null,
        _legalScopeManager = null,
        _variableChannelFactory = null,
        _variableWrapperFactory = null {
    _variableManager = VariableManager();
    // TODO: Load plugin functions via PluginFunctionLibrary.getInstance().getFunctions()
    // TODO: FormulaUtilities.loadBuiltInFunctions(_myFunctionLibrary)
    // TODO: LegalScopeUtilities.loadLegalScopeLibrary(_legalScopeManager)
    // TODO: Wire up FormulaSetupFactory suppliers
  }

  /// Returns the FormulaManager for this VariableContext (lazy instantiation).
  // TODO: Return type should be FormulaManager once translated.
  dynamic getFormulaManager() {
    _loadFormulaManager ??= _formulaSetupFactory?.generate();
    return _loadFormulaManager;
  }

  /// Returns a new FormulaManager; designed to be used once with each PC.
  // TODO: Return type should be FormulaManager once translated.
  dynamic getPCFormulaManager() {
    return _formulaSetupFactory?.generate();
  }

  /// Returns a FormulaModifier based on the given information.
  ///
  /// [modType]        – e.g. "ADD"
  /// [instructions]  – the modifier instructions string
  /// [formulaManager] – the FormulaManager in scope
  /// [varScope]       – the PCGenScope in which the modifier operates
  /// [formatManager]  – the FormatManager for the variable format
  // TODO: Restore generic parameter <T> and proper types when dependencies translate.
  dynamic getModifier(
    String modType,
    String instructions,
    dynamic formulaManager,
    dynamic varScope,
    FormatManager<dynamic> formatManager,
  ) {
    // TODO: Implement using TokenLibrary.getModifier, modifier.isValid, getDependencies
    throw UnimplementedError(
        'VariableContext.getModifier requires TokenLibrary and FormulaModifier (not yet translated)');
  }

  /// Adds a FormulaFunction to this VariableContext.
  void addFunction(FormulaFunction function) {
    _myFunctionLibrary.addFunction(function);
  }

  /// Returns the PCGenScope for the given name.
  // TODO: Return type should be PCGenScope once translated.
  dynamic getScope(String name) {
    // TODO: return (_legalScopeManager as ScopeManagerInst).getScope(name)
    return _legalScopeManager?.getScope(name);
  }

  /// Registers the given PCGenScope.
  void registerScope(dynamic scope) {
    // TODO: (_legalScopeManager as ScopeManagerInst).registerScope(scope)
    _legalScopeManager?.registerScope(scope);
  }

  /// Returns the collection of LegalScope objects for this context.
  List<dynamic> getScopes() {
    // TODO: return _legalScopeManager.getLegalScopes()
    return _legalScopeManager?.getLegalScopes() ?? const [];
  }

  /// Validates the default values provided to the formula system. Reports any
  /// errors to the logging system.
  void validateDefaults() {
    // TODO: final result = _solverFactory.validateDefaults();
    //        if (!result.get()) result.getMessages().forEach(Logging.errorPrint);
    _solverFactory?.validateDefaults();
  }

  /// Generates a SolverManager with a FormulaManager using the given
  /// WriteableVariableStore.
  SolverManager generateSolverManager(WriteableVariableStore varStore) {
    // TODO: Implement DynamicSolverManager once translated.
    throw UnimplementedError(
        'VariableContext.generateSolverManager requires DynamicSolverManager (not yet translated)');
  }

  /// Returns a valid NEPFormula for the given expression.
  ///
  /// Throws [ArgumentError] if the expression is not valid or does not produce
  /// an object of the type represented by [formatManager].
  NEPFormula<T> getValidFormula<T>(
    dynamic activeScope,
    FormatManager<T> formatManager,
    String instructions,
  ) {
    // TODO: Delegate to FormulaFactory.getValidFormula once translated.
    throw UnimplementedError(
        'VariableContext.getValidFormula requires FormulaFactory (not yet translated)');
  }

  /// Adds a relationship between a Solver format and a default Supplier for
  /// that format of Solver to this VariableContext.
  void addDefault<T>(FormatManager<T> varFormat, T Function() defaultValue) {
    // TODO: _solverFactory.addSolverFormat(varFormat, defaultValue)
    _solverFactory?.addSolverFormat(varFormat, defaultValue);
  }

  /// Returns the default value for a given Format.
  T getDefaultValue<T>(FormatManager<T> variableFormat) {
    // TODO: return _solverFactory.getDefault(variableFormat)
    return _solverFactory?.getDefault(variableFormat);
  }

  /// Returns true if there is a default modifier set for the given FormatManager.
  bool hasDefaultModifier(FormatManager<dynamic> formatManager) {
    // TODO: return _myValueStore.get(formatManager) != null
    return _myValueStore?.get(formatManager) != null;
  }

  // ---------------------------------------------------------------------------
  // VariableLibrary interface — delegated to VariableManager
  // ---------------------------------------------------------------------------

  @override
  bool isLegalVariableID(ImplementedScope varScope, String varName) {
    return _variableManager.isLegalVariableID(varScope, varName);
  }

  @override
  FormatManager<dynamic>? getVariableFormat(ImplementedScope varScope, String varName) {
    return _variableManager.getVariableFormat(varScope, varName);
  }

  @override
  VariableID<dynamic> getVariableID(ScopeInstance instance, String varName) {
    return _variableManager.getVariableID(instance, varName);
  }

  @override
  void assertLegalVariableID(
      String varName, ImplementedScope varScope, FormatManager<dynamic> formatManager) {
    _variableManager.assertLegalVariableID(varName, varScope, formatManager);
  }

  @override
  List<FormatManager<dynamic>> getInvalidFormats() {
    return _variableManager.getInvalidFormats();
  }

  @override
  T getDefault<T>(FormatManager<T> formatManager) {
    return _variableManager.getDefault(formatManager);
  }

  // ---------------------------------------------------------------------------
  // VariableChannelFactory interface — delegated to _variableChannelFactory
  // ---------------------------------------------------------------------------

  /// Returns a VariableChannel for the given owner and variable name.
  // TODO: Return type should be VariableChannel<?> once translated.
  dynamic getChannel(dynamic id, dynamic owner, String name) {
    return _variableChannelFactory?.getChannel(id, owner, name);
  }

  /// Returns a global VariableChannel for the given variable name.
  // TODO: Return type should be VariableChannel<?> once translated.
  dynamic getGlobalChannel(dynamic id, String name) {
    return _variableChannelFactory?.getGlobalChannel(id, name);
  }

  /// Disconnects the given VariableChannel.
  void disconnectChannel(dynamic variableChannel) {
    _variableChannelFactory?.disconnect(variableChannel);
  }

  // ---------------------------------------------------------------------------
  // VariableWrapperFactory interface — delegated to _variableWrapperFactory
  // ---------------------------------------------------------------------------

  /// Returns a VariableWrapper for the given owner and variable name.
  // TODO: Return type should be VariableWrapper<?> once translated.
  dynamic getWrapper(dynamic id, dynamic owner, String name) {
    return _variableWrapperFactory?.getWrapper(id, owner, name);
  }

  /// Returns a global VariableWrapper for the given variable name.
  // TODO: Return type should be VariableWrapper<?> once translated.
  dynamic getGlobalWrapper(dynamic id, String name) {
    return _variableWrapperFactory?.getGlobalWrapper(id, name);
  }

  /// Disconnects the given VariableWrapper.
  void disconnectWrapper(dynamic variableWrapper) {
    _variableWrapperFactory?.disconnect(variableWrapper);
  }
}
