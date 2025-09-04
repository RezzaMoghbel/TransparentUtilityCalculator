using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Utility.Readings;
using SimpleCRUD.DTO.Utility.Readings.Requests;

namespace SimpleCRUD.Engine.Test
{
    public class UtilityReadingHandler<T> where T : class
    {
        private readonly ICRUD<T> _repo;

        // DI constructor — the container will supply the CRUD<T> that we registered in Program.cs
        public UtilityReadingHandler(ICRUD<T> repo)
        {
            _repo = repo ?? throw new ArgumentNullException(nameof(repo));
        }

        public async Task<Result<IEnumerable<T>>> GetAllReadings(GetAllReadingsRequest request)
        {
            request.StoredProcedureName = "utility.UtilityReadings_ListByDate";
            return await UtilityReadings_ListByDate(request);
        }

        public async Task<Result<IEnumerable<T>>> GetAllUtilityTypes(bool onlyActive)
        {
            string spName = "utility.UtilityType_GetAll";
            return await UtilityTypes_GetAll(spName, onlyActive);
        }

        private async Task<Result<IEnumerable<T>>> UtilityReadings_ListByDate(GetAllReadingsRequest request)
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

        private async Task<Result<IEnumerable<T>>> UtilityTypes_GetAll(string spName, bool onlyActive)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { OnlyActive = onlyActive }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> CreateUtilityReading(UtilityReadingCreate urCreate)
        {
            string spName = "utility.UtilityReadings_Insert";
            return await UtilityReading_Create(spName, urCreate);
        }

        private async Task<Result<IEnumerable<T>>> UtilityReading_Create(string spName, UtilityReadingCreate urCreate)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        urCreate.UtilityTypeId,
                        urCreate.UserId,
                        urCreate.UnitRate,
                        urCreate.StandingChargePerDay,
                        urCreate.VatRateFactor,
                        urCreate.ReadingStartDate,
                        urCreate.ReadingEndDate,
                        urCreate.MeterStart,
                        urCreate.MeterEnd,
                        urCreate.ProviderDebitAmount,
                        urCreate.ProviderDebitDate,
                        urCreate.Notes
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetUtilityReadingsByID(string userID, int Id)
        {
            string spName = "utility.UtilityReadings_GetById";
            return await UtilityReadings_GetByID(spName, userID, Id);
        }

        private async Task<Result<IEnumerable<T>>> UtilityReadings_GetByID(string spName, string userId, int Id)
        {
            if (Id < 1)
            {
                return Result<IEnumerable<T>>.Fail("Invalid ID supplied.");
            }
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        Id,
                        UserId = userId
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> UpdateUtilityReading(UtilityReadingUpdate urUpdate)
        {
            string spName = "utility.UtilityReadings_Update";
            return await UtilityReading_Update(spName, urUpdate);
        }

        private async Task<Result<IEnumerable<T>>> UtilityReading_Update(string spName, UtilityReadingUpdate urUpdate)
        {
            if (urUpdate.Id < 1)
            {
                return Result<IEnumerable<T>>.Fail("Invalid ID supplied.");
            }
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        urUpdate.Id,
                        urUpdate.UtilityTypeId,
                        urUpdate.UserId,
                        urUpdate.UnitRate,
                        urUpdate.StandingChargePerDay,
                        urUpdate.VatRateFactor,
                        urUpdate.ReadingStartDate,
                        urUpdate.ReadingEndDate,
                        urUpdate.MeterStart,
                        urUpdate.MeterEnd,
                        urUpdate.ProviderDebitAmount,
                        urUpdate.ProviderDebitDate,
                        urUpdate.Notes
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> DeleteUtilityReading(UtilityReading ur)
        {
            string spName = "utility.UtilityReadings_Delete";
            return await UtilityReading_Delete(spName, ur);
        }

        private async Task<Result<IEnumerable<T>>> UtilityReading_Delete(string spName, UtilityReading ur)
        {
            if (ur.Id < 1 || ur.UserId is null)
            {
                return Result<IEnumerable<T>>.Fail("Invalid ID supplied.");
            }
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new
                    {
                        ur.Id,
                        ur.UserId
                    });
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }
    }
}
