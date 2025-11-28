using System;
using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Support;

namespace SimpleCRUD.Engine.Support;

public class SupportLookupHandler
{
    private readonly ICRUD<IssueCategory> _categoryRepo;
    private readonly ICRUD<TicketStatus> _statusRepo;
    private readonly ICRUD<TicketPriority> _priorityRepo;
    private readonly ICRUD<AnnouncementScope> _scopeRepo;
    private readonly ICRUD<BuildingOption> _buildingRepo;

    public SupportLookupHandler(
        ICRUD<IssueCategory> categoryRepo,
        ICRUD<TicketStatus> statusRepo,
        ICRUD<TicketPriority> priorityRepo,
        ICRUD<AnnouncementScope> scopeRepo,
        ICRUD<BuildingOption> buildingRepo)
    {
        _categoryRepo = categoryRepo ?? throw new ArgumentNullException(nameof(categoryRepo));
        _statusRepo = statusRepo ?? throw new ArgumentNullException(nameof(statusRepo));
        _priorityRepo = priorityRepo ?? throw new ArgumentNullException(nameof(priorityRepo));
        _scopeRepo = scopeRepo ?? throw new ArgumentNullException(nameof(scopeRepo));
        _buildingRepo = buildingRepo ?? throw new ArgumentNullException(nameof(buildingRepo));
    }

    public Task<Result<IEnumerable<IssueCategory>>> GetIssueCategoriesAsync()
        => ExecuteAsync(_categoryRepo, "support.IssueCategory_GetAll");

    public Task<Result<IEnumerable<TicketStatus>>> GetTicketStatusesAsync()
        => ExecuteAsync(_statusRepo, "support.TicketStatus_GetAll");

    public Task<Result<IEnumerable<TicketPriority>>> GetTicketPrioritiesAsync()
        => ExecuteAsync(_priorityRepo, "support.TicketPriority_GetAll");

    public Task<Result<IEnumerable<AnnouncementScope>>> GetAnnouncementScopesAsync()
        => ExecuteAsync(_scopeRepo, "support.AnnouncementScope_GetAll");

    public Task<Result<IEnumerable<BuildingOption>>> GetActiveBuildingsAsync()
        => ExecuteAsync(_buildingRepo, "dbo.Buildings_GetActive");

    private static async Task<Result<IEnumerable<T>>> ExecuteAsync<T>(ICRUD<T> repo, string storedProcedure) where T : class
    {
        try
        {
            var data = await repo.ExecuteStoredProcedureAsync<T>(storedProcedure);
            return Result<IEnumerable<T>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<T>>.Fail(ex.Message);
        }
    }
}

