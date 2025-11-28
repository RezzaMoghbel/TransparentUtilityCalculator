using System;
using System.Linq;
using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Support;

namespace SimpleCRUD.Engine.Support;

public class SupportAnnouncementHandler
{
    private readonly ICRUD<SupportAnnouncement> _announcementRepo;
    private readonly ICRUD<SupportAnnouncementUpdate> _updateRepo;

    public SupportAnnouncementHandler(
        ICRUD<SupportAnnouncement> announcementRepo,
        ICRUD<SupportAnnouncementUpdate> updateRepo)
    {
        _announcementRepo = announcementRepo ?? throw new ArgumentNullException(nameof(announcementRepo));
        _updateRepo = updateRepo ?? throw new ArgumentNullException(nameof(updateRepo));
    }

    public Task<Result<IEnumerable<SupportAnnouncement>>> GetAnnouncementsAsync(AnnouncementListRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        return ExecuteAsync(
            "support.Announcement_GetForBuilding",
            new
            {
                request.BuildingId,
                request.ScopeCode,
                request.CategoryCode,
                IsActive = request.IsActive,
                IncludeArchived = request.IncludeArchived ? 1 : 0,
                request.PageNumber,
                request.PageSize
            });
    }

    public Task<Result<IEnumerable<SupportAnnouncement>>> GetGlobalAnnouncementsAsync(AnnouncementListRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        return ExecuteAsync(
            "support.Announcement_GetGlobal",
            new
            {
                request.CategoryCode,
                IsActive = request.IsActive,
                IncludeArchived = request.IncludeArchived ? 1 : 0,
                request.PageNumber,
                request.PageSize
            });
    }

    public async Task<Result<SupportAnnouncement>> CreateAnnouncementAsync(AnnouncementCreateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var created = await _announcementRepo.ExecuteStoredProcedureAsync<SupportAnnouncement>(
                "support.Announcement_Create",
                new
                {
                    request.Title,
                    request.Body,
                    request.CategoryId,
                    request.ScopeId,
                    request.BuildingId,
                    request.SourceTicketId,
                    request.CreatedByUserId,
                    request.PublishedAt,
                    request.IsActive
                });

            var newId = created.FirstOrDefault()?.Id ?? 0;
            if (newId == 0)
            {
                return Result<SupportAnnouncement>.Fail("Announcement creation failed.");
            }

            return await GetAnnouncementByIdAsync(newId);
        }
        catch (Exception ex)
        {
            return Result<SupportAnnouncement>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportAnnouncement>> UpdateAnnouncementAsync(AnnouncementUpdateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var updated = await _announcementRepo.ExecuteStoredProcedureAsync<SupportAnnouncement>(
                "support.Announcement_Update",
                new
                {
                    request.Id,
                    request.Title,
                    request.Body,
                    request.CategoryId,
                    request.ScopeId,
                    request.BuildingId,
                    request.SourceTicketId,
                    request.IsActive,
                    request.IsArchived,
                    request.PublishedAt
                });

            var updatedId = updated.FirstOrDefault()?.Id ?? request.Id;
            return await GetAnnouncementByIdAsync(updatedId);
        }
        catch (Exception ex)
        {
            return Result<SupportAnnouncement>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportAnnouncement>> ArchiveAnnouncementAsync(int id)
    {
        try
        {
            var result = await _announcementRepo.ExecuteStoredProcedureAsync<SupportAnnouncement>(
                "support.Announcement_Archive",
                new { Id = id });

            var updatedId = result.FirstOrDefault()?.Id ?? id;
            return await GetAnnouncementByIdAsync(updatedId);
        }
        catch (Exception ex)
        {
            return Result<SupportAnnouncement>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportAnnouncement>> GetAnnouncementByIdAsync(int id)
    {
        try
        {
            var data = await _announcementRepo.ExecuteStoredProcedureAsync<SupportAnnouncement>(
                "support.Announcement_GetById",
                new { Id = id });

            var announcement = data.FirstOrDefault();
            return announcement is null
                ? Result<SupportAnnouncement>.Fail("Announcement not found.")
                : Result<SupportAnnouncement>.Success(announcement);
        }
        catch (Exception ex)
        {
            return Result<SupportAnnouncement>.Fail(ex.Message);
        }
    }

    public Task<Result<IEnumerable<SupportAnnouncementUpdate>>> GetUpdatesAsync(int announcementId)
    {
        return ExecuteUpdatesAsync(
            "support.AnnouncementUpdate_GetByAnnouncementId",
            new { AnnouncementId = announcementId });
    }

    public async Task<Result<SupportAnnouncementUpdate>> CreateUpdateAsync(AnnouncementUpdateCreateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var data = await _updateRepo.ExecuteStoredProcedureAsync<SupportAnnouncementUpdate>(
                "support.AnnouncementUpdate_Create",
                new
                {
                    request.AnnouncementId,
                    request.Body,
                    request.CreatedByUserId
                });

            var update = data.FirstOrDefault();
            return update is null
                ? Result<SupportAnnouncementUpdate>.Fail("Unable to append update.")
                : Result<SupportAnnouncementUpdate>.Success(update);
        }
        catch (Exception ex)
        {
            return Result<SupportAnnouncementUpdate>.Fail(ex.Message);
        }
    }

    private async Task<Result<IEnumerable<SupportAnnouncement>>> ExecuteAsync(string storedProcedure, object parameters)
    {
        try
        {
            var data = await _announcementRepo.ExecuteStoredProcedureAsync<SupportAnnouncement>(storedProcedure, parameters);
            return Result<IEnumerable<SupportAnnouncement>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<SupportAnnouncement>>.Fail(ex.Message);
        }
    }

    private async Task<Result<IEnumerable<SupportAnnouncementUpdate>>> ExecuteUpdatesAsync(string storedProcedure, object parameters)
    {
        try
        {
            var data = await _updateRepo.ExecuteStoredProcedureAsync<SupportAnnouncementUpdate>(storedProcedure, parameters);
            return Result<IEnumerable<SupportAnnouncementUpdate>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<SupportAnnouncementUpdate>>.Fail(ex.Message);
        }
    }
}

