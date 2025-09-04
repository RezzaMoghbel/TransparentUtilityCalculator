namespace SimpleCRUD.Data.RepositoriesAbstractions;

public interface ICRUD<T> where T : class
{
    Task<IEnumerable<TResult>> ExecuteStoredProcedureAsync<TResult>(string procedureName, object? parameters = null);
}
