using SimpleCRUD.Data.RepositoriesAbstractions;
using SimpleCRUD.DTO.Identity;
using System.Threading; // if you add cancellation support

namespace SimpleCRUD.Engine.Identity
{
    public class IdentityAccessLevelHandler<T> where T : class
    {
        private readonly ICRUD<T> _repo;

        // DI constructor — the container will supply the CRUD<T> that we registered in Program.cs
        public IdentityAccessLevelHandler(ICRUD<T> repo)
        {
            _repo = repo ?? throw new ArgumentNullException(nameof(repo));
        }

        // Todo: send CancellationToken for better server scalability
        public async Task<Result<IEnumerable<T>>> GetAll(/* CancellationToken ct = default */)
        {
            try
            {
                //Use the injected repo; no direct config or newing up here
                var data = await _repo.ExecuteStoredProcedureAsync<T>("identityAccessLevel.GetAll"/*, parameters: null, ct*/);
                return Result<IEnumerable<T>>.Success(data);
            }
            catch (Exception ex)
            {
                return Result<IEnumerable<T>>.Fail(ex.Message);
            }
        }
    }
}
