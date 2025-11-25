using HizliCagriAPI.Models;
using Microsoft.EntityFrameworkCore;

namespace HizliCagriAPI.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<TaskItem> TaskItems { get; set; } // Adını TaskItem yapmıştık
        public DbSet<Call> Calls { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Task tablosunda iki tane User ilişkisi olduğu için (Alan ve Veren)
            // SQL Server'da "Multiple Cascade Paths" hatası almamak için silme davranışını kısıtlıyoruz.
            
            modelBuilder.Entity<TaskItem>()
                .HasOne(t => t.AssignedToUser)
                .WithMany()
                .HasForeignKey(t => t.AssignedToUserId)
                .OnDelete(DeleteBehavior.Restrict); // Sekreter silinirse görevi silme (hata ver)

            modelBuilder.Entity<TaskItem>()
                .HasOne(t => t.AssignedByUser)
                .WithMany()
                .HasForeignKey(t => t.AssignedByUserId)
                .OnDelete(DeleteBehavior.Restrict);
        }
    }
}