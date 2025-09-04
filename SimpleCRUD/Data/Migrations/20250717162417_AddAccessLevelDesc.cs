using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SimpleCRUD.Migrations
{
    /// <inheritdoc />
    public partial class AddAccessLevelDesc : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 1,
            //    column: "Description",
            //    value: "Standard authenticated user with access to their own data (e.g., policies, claims, profile).");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 2,
            //    column: "Description",
            //    value: "In-house staff with permissions to manage users, content, claims, and business operations (excluding system configuration).");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 3,
            //    column: "Description",
            //    value: "Full system access including role management, configurations, audit logs, and administrative overrides.");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 4,
            //    column: "Description",
            //    value: "Reserved for automated internal processes such as scheduled tasks, integrations, or system-generated actions.");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 1,
            //    column: "Description",
            //    value: "");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 2,
            //    column: "Description",
            //    value: "");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 3,
            //    column: "Description",
            //    value: "");

            //migrationBuilder.UpdateData(
            //    table: "AccessLevels",
            //    keyColumn: "Id",
            //    keyValue: 4,
            //    column: "Description",
            //    value: "");
        }
    }
}
