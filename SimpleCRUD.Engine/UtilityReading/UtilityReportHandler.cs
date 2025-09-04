using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;

namespace SimpleCRUD.Engine.Test;

public class UtilityReportHandler<T> where T : class
{
    private readonly ICRUD<T> _repo;

    // DI constructor — the container will supply the CRUD<T> that we registered in Program.cs
    public UtilityReportHandler(ICRUD<T> repo)
    {
        _repo = repo ?? throw new ArgumentNullException(nameof(repo));
    }

    public async Task<Result<IEnumerable<T>>> GetMonthlyUsage(
        string userId, string typeName, string? fromDate = null, string? toDate = null)
    {
        var spName = "utility.rpt_MonthlyUsage_ByType";
        return await GetMonthlyUsage_ByType(spName, userId, typeName, fromDate, toDate);
    }

    private async Task<Result<IEnumerable<T>>> GetMonthlyUsage_ByType(
        string spName, string userId, string typeName, string? fromDate = null, string? toDate = null)
    {
        try
        {
            var data = await _repo.ExecuteStoredProcedureAsync<T>(
                spName,
                new { UserId = userId, TypeName = typeName, From = fromDate, To = toDate }
            );
            return Result<IEnumerable<T>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<T>>.Fail(ex.Message);
        }
    }

    public async Task<Result<IEnumerable<T>>> GetMonthlyAmount(
        string userId, string typeName, string? fromDate = null, string? toDate = null)
    {
        var spName = "utility.rpt_MonthlyAmount_ByType";
        return await GetMonthlyAmount_ByType(spName, userId, typeName, fromDate, toDate);
    }

    private async Task<Result<IEnumerable<T>>> GetMonthlyAmount_ByType(
        string spName, string userId, string typeName, string? fromDate = null, string? toDate = null)
    {
        try
        {
            var data = await _repo.ExecuteStoredProcedureAsync<T>(
                spName,
                new { UserId = userId, TypeName = typeName, From = fromDate, To = toDate }
            );
            return Result<IEnumerable<T>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<T>>.Fail(ex.Message);
        }
    }
}
