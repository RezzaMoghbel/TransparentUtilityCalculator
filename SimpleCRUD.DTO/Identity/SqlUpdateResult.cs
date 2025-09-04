using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SimpleCRUD.DTO.Identity
{
    public class SqlUpdateResult
    {
        public string? UpdatedId { get; set; }
    }
    public class SqlInsertResult
    {
        public string? InsertedId { get; set; }
    }
}
