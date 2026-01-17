using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HizliCagriAPI.Migrations
{
    /// <inheritdoc />
    public partial class UpdateScheduleItemWithStatusAndFeedback : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Calls");

            migrationBuilder.RenameColumn(
                name: "Description",
                table: "ScheduleItems",
                newName: "Status");

            migrationBuilder.AddColumn<string>(
                name: "Feedback",
                table: "ScheduleItems",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Feedback",
                table: "ScheduleItems");

            migrationBuilder.RenameColumn(
                name: "Status",
                table: "ScheduleItems",
                newName: "Description");

            migrationBuilder.CreateTable(
                name: "Calls",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CallTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CallerId = table.Column<int>(type: "int", nullable: false),
                    IsSeen = table.Column<bool>(type: "bit", nullable: false),
                    ReceiverId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Calls", x => x.Id);
                });
        }
    }
}
