using System;
using System.Linq;
using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Support;

namespace SimpleCRUD.Engine.Support;

public class SupportTicketMessageHandler
{
    private readonly ICRUD<SupportTicketMessage> _repo;

    public SupportTicketMessageHandler(ICRUD<SupportTicketMessage> repo)
    {
        _repo = repo ?? throw new ArgumentNullException(nameof(repo));
    }

    public Task<Result<IEnumerable<SupportTicketMessage>>> GetMessagesAsync(TicketMessageListRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        return ExecuteAsync(
            "support.TicketMessage_GetByTicketId",
            new
            {
                request.TicketId,
                IncludeInternal = request.IncludeInternal ? 1 : 0
            });
    }

    public async Task<Result<SupportTicketMessage>> CreateMessageAsync(TicketMessageCreateRequest request)
    {
        ArgumentNullException.ThrowIfNull(request);

        try
        {
            var data = await _repo.ExecuteStoredProcedureAsync<SupportTicketMessage>(
                "support.TicketMessage_Create",
                new
                {
                    request.TicketId,
                    request.Body,
                    request.CreatedByUserId,
                    request.IsInternal
                });

            var message = data.FirstOrDefault();
            return message is null
                ? Result<SupportTicketMessage>.Fail("Unable to add message.")
                : Result<SupportTicketMessage>.Success(message);
        }
        catch (Exception ex)
        {
            return Result<SupportTicketMessage>.Fail(ex.Message);
        }
    }

    private async Task<Result<IEnumerable<SupportTicketMessage>>> ExecuteAsync(string storedProcedure, object parameters)
    {
        try
        {
            var data = await _repo.ExecuteStoredProcedureAsync<SupportTicketMessage>(storedProcedure, parameters);
            return Result<IEnumerable<SupportTicketMessage>>.Success(data);
        }
        catch (Exception ex)
        {
            return Result<IEnumerable<SupportTicketMessage>>.Fail(ex.Message);
        }
    }
}

