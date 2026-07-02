class AppStrings {
  static const appName = 'Gastos';
  static const save = 'GUARDAR GASTO';
  static const noteHint = 'Nota (opcional)...';
  static const addNote = '+ Agregar nota';
  static const noLimit = 'Sin límite';
  static const budgetExceeded = 'Límite superado';
  static const deleteExpenseMsg = 'Gasto eliminado';
  static const undo = 'Deshacer';
  static const noExpenses = 'Sin gastos aún';
  static const noExpensesDesc = 'Registra tu primer gasto arriba';
  static const setLimit = 'Establecer límite';
  static const removeLimit = 'Sin límite';
  static const removeNote = 'Sin nota';
  static const editLimit = 'Editar límite';
  static const overallLimitTitle = 'Límite total del mes';
  static const categoryBudgets = 'Metas por categoría';
  static const saveLabel = 'Guardar';
  static const cancel = 'Cancelar';
  static const limitLabel = 'Límite máximo (\$)';
  static const tabHome = 'Inicio';
  static const tabHistory = 'Historial';
  static const tabStats = 'Estadísticas';
  static const tabBudgets = 'Metas';

  static String monthName(int month) {
    const names = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return names[month];
  }

  static String monthKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}';
}
