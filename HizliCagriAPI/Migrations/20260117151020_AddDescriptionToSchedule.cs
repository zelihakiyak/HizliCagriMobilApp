using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HizliCagriAPI.Migrations
{
    /// <inheritdoc />
    public partial class AddDescriptionToSchedule : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Description",
                table: "ScheduleItems",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Description",
                table: "ScheduleItems");
        }
    }
}
