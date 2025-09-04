using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace SimpleCRUD.Migrations
{
    /// <inheritdoc />
    public partial class AddAccessLevelAndAccessAllowed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "AccessAllowed",
                table: "AspNetUsers",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<int>(
                name: "AccessLevelId",
                table: "AspNetUsers",
                type: "int",
                nullable: false,
                defaultValue: 1);

            migrationBuilder.CreateTable(
                name: "AccessLevels",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccessLevels", x => x.Id);
                });

            migrationBuilder.InsertData(
                table: "AccessLevels",
                columns: new[] { "Id", "Name", "Description" },
                columnTypes: new[] { "int", "nvarchar(max)", "nvarchar(500)" },
                values: new object[,]
                {
            { 1, "User", "Standard authenticated user with access to their own data (e.g., policies, claims, profile)." },
            { 2, "Admin", "In-house staff with permissions to manage users, content, claims, and business operations (excluding system configuration)." },
            { 3, "SuperAdmin", "Full system access including role management, configurations, audit logs, and administrative overrides." },
            { 4, "System", "Reserved for automated internal processes such as scheduled tasks, integrations, or system-generated actions." }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AspNetUsers_AccessLevelId",
                table: "AspNetUsers",
                column: "AccessLevelId");

            migrationBuilder.AddForeignKey(
                name: "FK_AspNetUsers_AccessLevels_AccessLevelId",
                table: "AspNetUsers",
                column: "AccessLevelId",
                principalTable: "AccessLevels",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }


        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AspNetUsers_AccessLevels_AccessLevelId",
                table: "AspNetUsers");

            migrationBuilder.DropTable(
                name: "AccessLevels");

            migrationBuilder.DropIndex(
                name: "IX_AspNetUsers_AccessLevelId",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "AccessAllowed",
                table: "AspNetUsers");

            migrationBuilder.DropColumn(
                name: "AccessLevelId",
                table: "AspNetUsers");
        }
    }
}
