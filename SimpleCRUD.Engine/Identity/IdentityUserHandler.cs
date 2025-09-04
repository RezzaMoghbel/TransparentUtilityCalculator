using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using SimpleCRUD.DTO.Identity.Responses;

namespace SimpleCRUD.Engine.Test
{
    public class IdentityUserHandler<T> where T : class
    {
        private readonly ICRUD<T> _repo;

        // DI constructor — the container will supply the CRUD<T> that we registered in Program.cs
        public IdentityUserHandler(ICRUD<T> repo)
        {
            _repo = repo ?? throw new ArgumentNullException(nameof(repo));
        }

        public async Task<Result<IEnumerable<T>>> UserManageAccountExtras(string userName)
        {
            return await Get_UserManageAccountExtras("identity.ActiveUser_GetExtrasInfo_ByUserName", userName);
        }

        private async Task<Result<IEnumerable<T>>> Get_UserManageAccountExtras(string spName, string userName)
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<T>(
                    spName,
                    new { UserName = userName }
                );
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<T>>> GetAll()
        {
            return await GetAllUsers("identityUsers.GetAll");
        }
        public async Task<Result<IEnumerable<T>>> GetAll_Active()
        {
            return await GetAllUsers("identityUsers.GetAll_Active");
        }
        public async Task<Result<IEnumerable<T>>> GetAll_Inactive()
        {
            return await GetAllUsers("identityUsers.GetAll_Inactive");
        }
        public async Task<Result<IEnumerable<T>>> GetAll_Lockedout()
        {
            return await GetAllUsers("identityUsers.GetAll_Lockedout");
        }
        public async Task<Result<IEnumerable<T>>> GetAll_Deleted()
        {
            return await GetAllUsers("identityUsers.GetAll_Deleted");
        }

        private async Task<Result<IEnumerable<T>>> GetAllUsers(string spName)
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

        public async Task<Result<User>> GetOne(string id)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<User>(
                    "identityUsers.GetById",
                    new { Id = id }
                );

                var user = result.FirstOrDefault();
                if (user == null)
                {
                    return Result<User>.Fail("User not found.");
                }

                return Result<User>.Success(user);
            }
            catch (Exception ex)
            {
                return Result<User>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> Delete(string id)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<string>(
                    "identityUsers.Delete",
                    new { Id = id } // match parameter name in stored proc
                );

                var deletedId = result.FirstOrDefault();

                if (deletedId == "-1" || string.IsNullOrEmpty(deletedId))
                    return Result<string>.Fail("User not found or deletion failed.");

                return Result<string>.Success(deletedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> RestoreUser(string id)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<string>(
                    "identityUsers.RestoreUser",
                    new { Id = id } // match parameter name in stored proc
                );

                var deletedId = result.FirstOrDefault();

                if (deletedId == "-1" || string.IsNullOrEmpty(deletedId))
                    return Result<string>.Fail("User not found or restore user failed.");

                return Result<string>.Success(deletedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> SetAccessAllowed(string id, bool isAllowed)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<SqlUpdateResult>(
                    "identityUsers.SetAccessAllowed",
                    new { Id = id, AccessAllowed = isAllowed }
                );

                SqlUpdateResult? row = result.FirstOrDefault();
                if (row == null || row.UpdatedId == "-1" || row.UpdatedId == null)
                {
                    return Result<string>.Fail("User not found or update failed.");
                }
                return Result<string>.Success(row.UpdatedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> UpdateUser(User user)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<SqlUpdateResult>(
                    "identityUsers.Update",
                    new
                    {
                        Id = user.ID,
                        EmailConfirmed = user.EmailConfirmed,
                        PhoneNumber = user.PhoneNumber,
                        PhoneNumberConfirmed = user.PhoneNumberConfirmed,
                        TwoFactorEnabled = user.TwoFactorEnabled,
                        LockoutEnd = user.LockoutEnd,
                        LockoutEnabled = user.LockoutEnabled,
                        AccessFailedCount = user.AccessFailedCount,
                        AccessAllowed = user.AccessAllowed,
                        AccessLevelId = user.AccessLevelId ?? 1
                    });

                SqlUpdateResult? row = result.FirstOrDefault();

                if (row == null || row.UpdatedId == "-1" || string.IsNullOrEmpty(row.UpdatedId))
                {
                    return Result<string>.Fail("User update failed or user not found.");
                }

                return Result<string>.Success(row.UpdatedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<AccessLevel>>> GetAllAccessLevels()
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<AccessLevel>("identityUsers.GetAllAccessLevels");
                return Result<IEnumerable<AccessLevel>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<AccessLevel>>.Fail(ex.Message);
            }
        }

        public async Task<Result<IEnumerable<IPWhiteList>>> GetAllIPAddresses()
        {
            try
            {
                var data = await _repo.ExecuteStoredProcedureAsync<IPWhiteList>("identityUsers.GetAllIPWhiteList");
                return Result<IEnumerable<IPWhiteList>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<IPWhiteList>>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> DeleteIPWhiteList(int id)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<string>(
                    "identityUsers.DeleteIPWhiteList",
                    new { Id = id } // match parameter name in stored proc
                );

                var deletedId = result.FirstOrDefault();

                if (deletedId == "-1" || string.IsNullOrEmpty(deletedId))
                    return Result<string>.Fail("IP not found or deletion failed.");

                return Result<string>.Success(deletedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> ActivateIPAddress(int id, bool isActive)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<SqlUpdateResult>(
                    "identityUsers.ActivateIPAddress",
                    new { ID = id, IsActive = isActive } // keep as-is if your SP expects "ID"
                );

                SqlUpdateResult? row = result.FirstOrDefault();
                if (row == null || row.UpdatedId == "-1" || row.UpdatedId == null)
                {
                    return Result<string>.Fail("IP address not found or IP address activation failed.");
                }
                return Result<string>.Success(row.UpdatedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> InsertIPSafeList(IPWhiteList insertModel)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<SqlInsertResult>(
                    "identityUsers.InsertIPWhitelist",
                    new
                    {
                        IPAddress = insertModel.IPAddress,
                        UserId = string.IsNullOrWhiteSpace(insertModel.UserId) ? null : insertModel.UserId,
                        Description = insertModel.Description,
                        ExpiryDate = insertModel.ExpiryDate,
                        IsActive = insertModel.IsActive
                    });

                SqlInsertResult? row = result.FirstOrDefault();

                if (row == null || row.InsertedId == "-1" || string.IsNullOrEmpty(row.InsertedId))
                {
                    return Result<string>.Fail("User update failed or user not found.");
                }

                return Result<string>.Success(row.InsertedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> UpdateIPSafeList(IPWhiteList updateModel)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<SqlUpdateResult>(
                    "identityUsers.UpdateIPWhitelist",
                    new
                    {
                        Id = updateModel.ID,
                        IPAddress = updateModel.IPAddress,
                        UserId = string.IsNullOrWhiteSpace(updateModel.UserId) ? null : updateModel.UserId,
                        Description = updateModel.Description,
                        ExpiryDate = updateModel.ExpiryDate,
                        IsActive = updateModel.IsActive
                    });

                SqlUpdateResult? row = result.FirstOrDefault();

                if (row == null || row.UpdatedId == "-1" || row.UpdatedId == "-2" || string.IsNullOrEmpty(row.UpdatedId))
                {
                    return Result<string>.Fail("IPWhitelist update failed or user not found.");
                }

                return Result<string>.Success(row.UpdatedId);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }

        public async Task<Result<IPWhiteList>> GetOneIP(int id)
        {
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<IPWhiteList>(
                    "identityUsers.GetByIdIPAddressList",
                    new { Id = id }
                );

                var user = result.FirstOrDefault();
                if (user == null)
                {
                    return Result<IPWhiteList>.Fail("User not found.");
                }

                return Result<IPWhiteList>.Success(user);
            }
            catch (Exception ex)
            {
                return Result<IPWhiteList>.Fail(ex.Message);
            }
        }

        public async Task<Result<string>> GetUserIdByUsername(string? userName)
        {
            if (string.IsNullOrEmpty(userName))
            {
                return Result<string>.Fail("Username not found");
            }
            try
            {
                var result = await _repo.ExecuteStoredProcedureAsync<ActiveUser_GetByUserName>(
                    "identity.ActiveUser_GetByUserName",
                    new
                    {
                        UserName = userName
                    });

                ActiveUser_GetByUserName? row = result.FirstOrDefault();

                if (row == null || string.IsNullOrEmpty(row.Id))
                {
                    return Result<string>.Fail("Username not found");
                }

                return Result<string>.Success(row.Id);
            }
            catch (Exception ex)
            {
                return Result<string>.Fail(ex.Message);
            }
        }
    }
}
