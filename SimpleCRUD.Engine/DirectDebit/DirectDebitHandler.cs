using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Utility.DirectDebits;
using SimpleCRUD.DTO.Utility.Readings;

namespace SimpleCRUD.Engine.DirectDebit
{
    public class DirectDebitHandler<T> where T : class
    {
        private readonly ICRUD<T> _repo;

        // DI constructor — the container will supply the CRUD<T> that we registered in Program.cs
        public DirectDebitHandler(ICRUD<T> repo)
        {
            _repo = repo ?? throw new ArgumentNullException(nameof(repo));
        }

        public async Task<Result<IEnumerable<T>>> GetAllDirectDebits(DirectDebitsListByDateRequest request)
        {
            request.StoredProcedureName = "utility.DirectDebits_ListByDate";
            return await DirectDebits_ListByDate(request);
        }

        private async Task<Result<IEnumerable<T>>> DirectDebits_ListByDate(DirectDebitsListByDateRequest request)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    request.StoredProcedureName!,
                    new { request.UserId, request.FromDate, request.ToDate }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> CreateDirectDebit(DirectDebitCreate ddCreate)
        {
            string spName = "utility.DirectDebits_Insert";
            return await DirectDebit_Create(spName, ddCreate);
        }

        private async Task<Result<IEnumerable<T>>> DirectDebit_Create(string spName, DirectDebitCreate ddCreate)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        ddCreate.UserId,
                        ddCreate.Amount,
                        ddCreate.PaymentDate,
                        ddCreate.UtilityProviderId,
                        ddCreate.PaymentStatus,
                        ddCreate.Notes
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetDirectDebitById(string userID, int Id)
        {
            string spName = "utility.DirectDebits_GetById";
            return await DirectDebits_GetByID(spName, userID, Id);
        }

        private async Task<Result<IEnumerable<T>>> DirectDebits_GetByID(string spName, string userID, int Id)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { Id, UserId = userID }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> UpdateDirectDebit(DirectDebitUpdate ddUpdate)
        {
            string spName = "utility.DirectDebits_Update";
            return await DirectDebit_Update(spName, ddUpdate);
        }

        private async Task<Result<IEnumerable<T>>> DirectDebit_Update(string spName, DirectDebitUpdate ddUpdate)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        ddUpdate.Id,
                        ddUpdate.UserId,
                        ddUpdate.Amount,
                        ddUpdate.PaymentDate,
                        ddUpdate.UtilityProviderId,
                        ddUpdate.PaymentStatus,
                        ddUpdate.Notes
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> DeleteDirectDebit(DirectDebitDeleteRequest ddDelete)
        {
            string spName = "utility.DirectDebits_Delete";
            return await DirectDebit_Delete(spName, ddDelete);
        }

        private async Task<Result<IEnumerable<T>>> DirectDebit_Delete(string spName, DirectDebitDeleteRequest ddDelete)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { ddDelete.Id, ddDelete.UserId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        // Link management methods
        public async Task<Result<IEnumerable<T>>> LinkReadingToDirectDebit(int directDebitId, int utilityReadingId, string userId)
        {
            string spName = "utility.DirectDebitReadings_Link";
            return await LinkReading(spName, directDebitId, utilityReadingId, userId);
        }

        private async Task<Result<IEnumerable<T>>> LinkReading(string spName, int directDebitId, int utilityReadingId, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { DirectDebitId = directDebitId, UtilityReadingId = utilityReadingId, UserId = userId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> UnlinkReadingFromDirectDebit(int directDebitId, int utilityReadingId, string userId)
        {
            string spName = "utility.DirectDebitReadings_Unlink";
            return await UnlinkReading(spName, directDebitId, utilityReadingId, userId);
        }

        private async Task<Result<IEnumerable<T>>> UnlinkReading(string spName, int directDebitId, int utilityReadingId, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { DirectDebitId = directDebitId, UtilityReadingId = utilityReadingId, UserId = userId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetReadingsForDirectDebit(int directDebitId, string userId)
        {
            string spName = "utility.DirectDebitReadings_GetByDirectDebit";
            return await GetReadingsForDD(spName, directDebitId, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetReadingsForDD(string spName, int directDebitId, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { DirectDebitId = directDebitId, UserId = userId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetDirectDebitsForReading(int utilityReadingId, string userId)
        {
            string spName = "utility.DirectDebitReadings_GetByReading";
            return await GetDDsForReading(spName, utilityReadingId, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetDDsForReading(string spName, int utilityReadingId, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { UtilityReadingId = utilityReadingId, UserId = userId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetAllActiveProviders()
        {
            string spName = "dbo.UtilityProviders_GetAllActive";
            return await GetAllActiveProviders(spName);
        }

        private async Task<Result<IEnumerable<T>>> GetAllActiveProviders(string spName)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(spName);
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetAvailableReadingsForLinking(string userId)
        {
            string spName = "utility.UtilityReadings_GetAvailableForLinking";
            return await GetAvailableReadings(spName, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetAvailableReadings(string spName, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(spName, new { UserId = userId });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetDirectDebitBalances(string userId)
        {
            string spName = "utility.rpt_DirectDebits_Balance";
            return await GetBalances(spName, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetBalances(string spName, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(spName, new { UserId = userId });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetDirectDebitBalanceById(int directDebitId, string userId)
        {
            string spName = "utility.rpt_DirectDebits_BalanceById";
            return await GetBalanceById(spName, directDebitId, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetBalanceById(string spName, int directDebitId, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { DirectDebitId = directDebitId, UserId = userId }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetMonthlyComparison(string userId)
        {
            string spName = "utility.rpt_DirectDebits_MonthlyComparison";
            return await GetMonthlyData(spName, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetMonthlyData(string spName, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(spName, new { UserId = userId });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetOverallSummary(string userId)
        {
            string spName = "utility.rpt_DirectDebits_OverallSummary";
            return await GetOverallSummaryData(spName, userId);
        }

        private async Task<Result<IEnumerable<T>>> GetOverallSummaryData(string spName, string userId)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(spName, new { UserId = userId });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }
    }
}
