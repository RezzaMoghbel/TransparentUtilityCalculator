using System;
using System.Linq;
using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Support;

namespace SimpleCRUD.Engine.Support;

public class SupportTicketHandler
{
    private readonly ICRUD<SupportTicket> _ticketRepo;

    public SupportTicketHandler(ICRUD<SupportTicket> ticketRepo)
    {
        _ticketRepo = ticketRepo ?? throw new ArgumentNullException(nameof(ticketRepo));
    }

    public Task<Result<IEnumerable<SupportTicket>>> GetTicketsForUserAsync(TicketListRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        return ExecuteAsync(
            "support.Ticket_GetForUser",
            new
            {
                UserId = request.UserId,
                StatusCode = request.StatusCode,
                PriorityCode = request.PriorityCode,
                Search = request.Search,
                PageNumber = request.PageNumber,
                PageSize = request.PageSize
            });
    }

    public Task<Result<IEnumerable<SupportTicket>>> GetTicketsForBuildingAsync(TicketListRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        return ExecuteAsync(
            "support.Ticket_GetForBuilding",
            new
            {
                request.BuildingId,
                IncludeArchived = request.IncludeArchived ? 1 : 0,
                request.StatusCode,
                request.PriorityCode,
                request.AssignedToUserId,
                request.Search,
                request.PageNumber,
                request.PageSize
            });
    }

    public async Task<Result<SupportTicket>> CreateTicketAsync(TicketCreateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var created = await _ticketRepo.ExecuteStoredProcedureAsync<SupportTicket>(
                "support.Ticket_Create",
                new
                {
                    request.Title,
                    request.Description,
                    request.StatusId,
                    request.PriorityId,
                    request.CategoryId,
                    request.CreatedByUserId,
                    request.BuildingId,
                    request.AssignedToUserId,
                    request.RelatedUserId
                });

            var newId = created.FirstOrDefault()?.Id ?? 0;
            if (newId == 0)
            {
                return Result<SupportTicket>.Fail("Ticket creation failed.");
            }

            return await GetTicketByIdAsync(newId);
        }
        catch (Exception ex)
        {
            return Result<SupportTicket>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportTicket>> UpdateTicketAsync(TicketUpdateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var updated = await _ticketRepo.ExecuteStoredProcedureAsync<SupportTicket>(
                "support.Ticket_Update",
                new
                {
                    request.Id,
                    request.Title,
                    request.Description,
                    request.StatusId,
                    request.PriorityId,
                    request.CategoryId,
                    request.AssignedToUserId,
                    request.RelatedUserId,
                    request.BuildingId,
                    request.AnnouncementId,
                    request.ResolvedAt
                });

            var updatedId = updated.FirstOrDefault()?.Id ?? request.Id;
            return await GetTicketByIdAsync(updatedId);
        }
        catch (Exception ex)
        {
            return Result<SupportTicket>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportTicket>> ArchiveTicketAsync(TicketArchiveRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var archived = await _ticketRepo.ExecuteStoredProcedureAsync<SupportTicket>(
                "support.Ticket_Archive",
                new { request.Id });

            var archivedId = archived.FirstOrDefault()?.Id ?? request.Id;
            return await GetTicketByIdAsync(archivedId);
        }
        catch (Exception ex)
        {
            return Result<SupportTicket>.Fail(ex.Message);
        }
    }

    public async Task<Result<SupportTicket>> GetTicketByIdAsync(int id)
    {
        try
        {
            var data = await _ticketRepo.ExecuteStoredProcedureAsync<SupportTicket>(
                "support.Ticket_GetById",
                new { Id = id });

            var ticket = data.FirstOrDefault();
            return ticket is null
                ? Result<SupportTicket>.Fail("Ticket not found.")
                : Result<SupportTicket>.Success(ticket);
        }
        catch (Exception ex)
        {
            return Result<SupportTicket>.Fail(ex.Message);
        }
    }

    private async Task<Result<IEnumerable<SupportTicket>>> ExecuteAsync(string storedProcedure, object parameters)
    {
        try
        {
            var data = await _ticketRepo.ExecuteStoredProcedureAsync<SupportTicket>(storedProcedure, parameters);
            return Result<IEnumerable<SupportTicket>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<SupportTicket>>.Fail(ex.Message);
        }
    }
}

